#if !defined(MY_LIGHTMAPPING_INCLUDED)
#define MY_LIGHTMAPPING_INCLUDED

#include "UnityPBSLighting.cginc"
#include "UnityMetaPass.cginc"

#include "Helpers.cginc"
#include "Structs.cginc"

Lightmap_v2f vert(Lightmap_appdata v)
{
	Lightmap_v2f o;
	v.vertex.xy = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
	v.vertex.z = 0;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	o.section = GetSection(v.color);
	return o;
}

float4 frag(Lightmap_v2f i) : SV_TARGET
{
	float2 section = GetSectionLerped(i.section, i.uv);
	UnityMetaInput surfaceData;
	surfaceData.Albedo = GetAlbedo(section, i.uv);
	surfaceData.Emission = GetEmission(section, i.uv);
	surfaceData.SpecularColor = half3(1, 1, 1);
	float oneMinusReflectivity;
	float roughness = SmoothnessToRoughness(GetMetallic(section, i.uv).g) * 0.5;
	surfaceData.Albedo += surfaceData.SpecularColor * roughness;
	return UnityMetaFragment(surfaceData);
}

#endif
