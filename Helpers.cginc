#if !defined(MY_HELPERS_INCLUDED)
#define MY_HELPERS_INCLUDED

#include "Structs.cginc"

sampler2D _MainTex;
sampler2D _NormalMap;
sampler2D _EmissionMap;
sampler2D _MetallicMap;
sampler2D _OcclusionMap;
sampler2D _ParallaxMap;

float _ParallaxStrength;
float4 _MainTex_ST;
float4 _Color;
float4 _EmissionColor;
float _MetallicStrength;
float _SmoothnessStrength;
float _OcclusionStrength;
float _BumpScale;

float4 _DefaultSection;
float4 _Section1;
float4 _Section2;
float4 _Section3;
float4 _Section4;
float4 _Section5;
float4 _Section6;
float4 _Section7;
float4 _Section8;
float4 _Section9;
float4 _Section10;
float4 _Section11;
float4 _Section12;
float4 _Section13;
float4 _Section14;
float4 _Section15;
float4 _Section16;
float4 _Section17;
float4 _Section18;
float4 _Section19;
float4 _Section20;
float4 _Section21;
float4 _Section22;
float4 _Section23;
float4 _Section24;
float4 _Section25;
float4 _Section26;
float4 _Section27;
float4 _Section28;
float4 _Section29;
float4 _Section30;

fixed4 GetAlbedo(float2 section, float2 uv)
{
	return tex2D(_MainTex, section, ddx(uv), ddy(uv)).rgba * fixed4(_Color.rgb, 1);
}

fixed3 GetEmission(float2 section, float2 uv)
{
	#if defined(FORWARD_BASE_PASS)
		return tex2D(_EmissionMap, section, ddx(uv), ddy(uv)).rgb * fixed4(_EmissionColor.rgb, 1);
	#else
		return 0;
	#endif
}

fixed2 GetMetallic(float2 section, float2 uv)
{
	fixed4 smpl = tex2D(_MetallicMap, section, ddx(uv), ddy(uv));
	return fixed2(smpl.r * _MetallicStrength, smpl.a * _SmoothnessStrength);
}

float GetOcclusion(float2 section, float2 uv)
{
	return lerp(1, tex2D(_OcclusionMap, section, ddx(uv), ddy(uv)).g, _OcclusionStrength);
}

float GetParallaxHeight(float2 section, float2 uv)
{
	return tex2D(_ParallaxMap, section, ddx(uv), ddy(uv)).b;
}

float4 GetSection(float4 color)
{
	float4 section;
	float cmpr = color.b * 255;

	if (cmpr == 1) section = _Section1;
	else if (cmpr == 2) section = _Section2;
	else if (cmpr == 3) section = _Section3;
	else if (cmpr == 4) section = _Section4;
	else if (cmpr == 5) section = _Section5;
	else if (cmpr == 6) section = _Section6;
	else if (cmpr == 7) section = _Section7;
	else if (cmpr == 8) section = _Section8;
	else if (cmpr == 9) section = _Section9;
	else if (cmpr == 10) section = _Section10;
	else if (cmpr == 11) section = _Section11;
	else if (cmpr == 12) section = _Section12;
	else if (cmpr == 13) section = _Section13;
	else if (cmpr == 14) section = _Section14;
	else if (cmpr == 15) section = _Section15;
	else if (cmpr == 16) section = _Section16;
	else if (cmpr == 17) section = _Section17;
	else if (cmpr == 18) section = _Section18;
	else if (cmpr == 19) section = _Section19;
	else if (cmpr == 20) section = _Section20;
	else if (cmpr == 21) section = _Section21;
	else if (cmpr == 22) section = _Section22;
	else if (cmpr == 23) section = _Section23;
	else if (cmpr == 24) section = _Section24;
	else if (cmpr == 25) section = _Section25;
	else if (cmpr == 26) section = _Section26;
	else if (cmpr == 27) section = _Section27;
	else if (cmpr == 28) section = _Section28;
	else if (cmpr == 29) section = _Section29;
	else if (cmpr == 30) section = _Section30;
	else section = _DefaultSection;

	return section;
}

float2 GetSectionLerped(float4 section, float2 uv)
{
	return frac((uv - section.zw) / (section.xy - section.zw)) * (section.xy - section.zw) + section.zw;
}

void ComputeVertexLightColor(inout Lighting_v2f i)
{
	#if defined(VERTEXLIGHT_ON)
		i.vertexLightColor = Shade4PointLights(
			unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			unity_LightColor[0].rgb, unity_LightColor[1].rgb,
			unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			unity_4LightAtten0, i.worldPos, i.normal
		);
	#endif
}

float3 CreateBinormal(float3 normal, float3 tangent, float binormalSign) {
	return cross(normal, tangent.xyz) * (binormalSign * unity_WorldTransformParams.w);
}

void InitializeFragmentNormal(inout Lighting_v2f i, float2 section)
{
	float3 mainNormal = UnpackScaleNormal(tex2D(_NormalMap, section), _BumpScale);

	#if defined(_BINORMAL_PER_FRAGMENT)
		float3 binormal = CreateBinormal(i.normal, i.tangent.xyz, i.tangent.w);
	#else
		float3 binormal = i.binormal;
	#endif

	i.normal = normalize(
		mainNormal.x * i.tangent +
		mainNormal.y * binormal +
		mainNormal.z * i.normal
	);
}

float FadeShadows(Lighting_v2f i, float attenuation) {
	#if HANDLE_SHADOWS_BLENDING_IN_GI
		// UNITY_LIGHT_ATTENUATION doesn't fade shadows for us.
		float viewZ = dot(_WorldSpaceCameraPos - i.worldPos, UNITY_MATRIX_V[2].xyz);
		float shadowFadeDistance = UnityComputeShadowFadeDistance(i.worldPos, viewZ);
		float bakedAttenuation = UnitySampleBakedOcclusion(i.lightmapUV, i.worldPos);
		float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
		attenuation = UnityMixRealtimeAndBakedShadows(attenuation, bakedAttenuation, shadowFade);
	#endif

	return attenuation;
}
#endif
