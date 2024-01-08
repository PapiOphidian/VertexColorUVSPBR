#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

#include "Lightmapping.cginc"
#include "Parallax.cginc"
#include "Reflections.cginc"
#include "Helpers.cginc"
#include "Structs.cginc"

float4 _MainTex_TexelSize;
float _AlphaCutoff;
float _MipMappedSectionEdgeCompensation;
float _EmissionStrength;

Lighting_v2f vert(Lighting_appdata v)
{
	Lighting_v2f o;
	UNITY_INITIALIZE_OUTPUT(Lighting_v2f, o);
	o.pos = UnityObjectToClipPos(v.vertex);

	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	#if defined(LIGHTMAP_ON)
		o.lightmapUV = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
	#endif
	o.normal = UnityObjectToWorldNormal(v.normal);

	#if defined(_BINORMAL_PER_FRAGMENT)
		o.tangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
	#else
		o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
		o.binormal = CreateBinormal(o.normal, o.tangent, v.tangent.w);
	#endif
	o.worldPos = mul(unity_ObjectToWorld, v.vertex);
	o.color = v.color;
	o.section = GetSection(v.color);

	UNITY_TRANSFER_SHADOW(o, v.uv1);

	ComputeVertexLightColor(o);

	float3x3 objectToTangent = float3x3(
		v.tangent.xyz,
		cross(v.normal, v.tangent.xyz) * v.tangent.w,
		v.normal
	);
	o.tangentViewDir = mul(objectToTangent, ObjSpaceViewDir(v.vertex));

	return o;
}

UnityLight CreateLight(Lighting_v2f i)
{
	UnityLight light;
	#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
		light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
	#else
		light.dir = _WorldSpaceLightPos0.xyz;
	#endif

	UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
	attenuation = FadeShadows(i, attenuation);

	light.color = _LightColor0.rgb * attenuation;
	light.ndotl = DotClamped(i.normal, light.dir);
	return light;
}

UnityIndirect CreateIndirectLight(Lighting_v2f i, float3 viewDir, float smoothness, float2 section)
{
	UnityIndirect indirectLight;
	indirectLight.diffuse = 0;
	indirectLight.specular = 0;

	#if defined(VERTEXLIGHT_ON)
		indirectLight.diffuse = i.vertexLightColor;
	#endif


	#if defined(FORWARD_BASE_PASS)
		#if defined(LIGHTMAP_ON)
			indirectLight.diffuse = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV));
			#if defined(DIRLIGHTMAP_COMBINED)
				float4 lightmapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, i.lightmapUV);
				indirectLight.diffuse = DecodeDirectionalLightmap(indirectLight.diffuse, lightmapDirection, i.normal);
			#endif
		#else
			indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
		#endif


		UNITY_BRANCH
		if (smoothness > 0) { // Dont sample cube maps if there is no smoothness as it would be a wasted sample. Saves time.
			float3 reflectionDir = reflect(-viewDir, i.normal);

			Unity_GlossyEnvironmentData envData;
			envData.roughness = 1 - smoothness;
			half3 reflectionUV1 = BoxProjection(
				reflectionDir, i.worldPos,
				unity_SpecCube0_ProbePosition,
				unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax
			);
			envData.reflUVW = reflectionUV1;

			half4 probe0 = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflectionUV1);
			half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);

			#if UNITY_SPECCUBE_BLENDING
				float interpolator = unity_SpecCube0_BoxMin.w;
				UNITY_BRANCH
				if (interpolator < 0.99999)
				{
					half3 reflectionUV2 = BoxProjection(
						reflectionDir, i.worldPos,
						unity_SpecCube1_ProbePosition,
						unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax
					);
					half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0, reflectionUV2);
					half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
					indirectLight.specular = lerp(probe1sample, probe0sample, interpolator);
				} else indirectLight.specular = probe0sample;
			#else
				indirectLight.specular = probe0sample;
			#endif
		}

		UNITY_BRANCH
		if (_OcclusionStrength > 0) {
			float occlusion = GetOcclusion(section, i.uv);
			indirectLight.diffuse *= occlusion;
			indirectLight.specular *= occlusion;
		}
	#endif

	return indirectLight;
}

fixed4 frag(Lighting_v2f i) : SV_TARGET
{
	float3 viewDir;
	UNITY_BRANCH
	if (_BumpScale > 0 || _SmoothnessStrength > 0 || _MetallicStrength > 0) viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
	else viewDir = float3(0, 0, 0);

	float2 section = GetSectionLerped(
		i.section
			+ float4(_MainTex_TexelSize.xy * _MipMappedSectionEdgeCompensation, 0, 0)
			- float4(0, 0, _MainTex_TexelSize.xy * _MipMappedSectionEdgeCompensation),
		i.uv
	);

	fixed4 albedo = GetAlbedo(section, i.uv);
	UNITY_BRANCH
	if (_ParallaxStrength > 0) ApplyParallax(i, section);
	UNITY_BRANCH
	if (_BumpScale > 0) InitializeFragmentNormal(i, section);

	fixed2 metsmooth;
	UNITY_BRANCH
	if (_SmoothnessStrength > 0 || _MetallicStrength > 0) metsmooth = GetMetallic(section, i.uv);
	else metsmooth = fixed2(0, 0);

	if ((albedo.a - _AlphaCutoff) < 0 && metsmooth.r == 0 && metsmooth.g == 0) discard;

	float3 specularTint;
	if (albedo.r > 0 || albedo.g > 0 || albedo.b > 0) specularTint = albedo * metsmooth.r;
	else specularTint = float3(1, 1, 1);
	float oneMinusReflectivity = 1 - metsmooth.r;

	float4 color = UNITY_BRDF_PBS(albedo, specularTint, oneMinusReflectivity, metsmooth.g, i.normal, viewDir, CreateLight(i), CreateIndirectLight(i, viewDir, metsmooth.g, section));
	UNITY_BRANCH
	if (_EmissionStrength > 0) color.rgb += (GetEmission(section, i.uv) * _EmissionStrength);
	return color;
}
#endif
