#if !defined(MY_STRUCTS_INCLUDED)
#define MY_STRUCTS_INCLUDED

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

struct Lighting_appdata
{
	float2 uv : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float2 uv2 : TEXCOORD2;
	float3 tangentViewDir : TEXCOORD3;
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float4 color : COLOR;
};

struct Lighting_v2f
{
	float4 color : TEXCOORD9;
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : TEXCOORD1;

	#if defined(_BINORMAL_PER_FRAGMENT)
		float4 tangent : TEXCOORD2;
	#else
		float3 tangent : TEXCOORD2;
		float3 binormal : TEXCOORD3;
	#endif

	float3 worldPos : TEXCOORD4;

	#if defined(VERTEXLIGHT_ON)
		float3 vertexLightColor : TEXCOORD5;
	#endif

	#if defined(LIGHTMAP_ON)
		float2 lightmapUV : TEXCOORD5;
	#endif

	UNITY_SHADOW_COORDS(6)

	float4 section : TEXCOORD7;
	float3 tangentViewDir : TEXCOORD8;
};

struct Lightmap_appdata {
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float4 color : COLOR;
};

struct Lightmap_v2f {
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	float4 section : TEXCOORD1;
};

struct Shadows_appdata
{
	float4 position : POSITION;
	float3 normal : NORMAL;
};

struct Shadows_v2f {
	float4 position : SV_POSITION;
	float3 lightVec : TEXCOORD0;
};
#endif
