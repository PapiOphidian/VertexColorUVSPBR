Shader "PapiOphidian/VertexColorUVsPBR"
{
	Properties
	{
		_Color("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_MipMappedSectionEdgeCompensation("Mip Section Edge Compensation (pixels)", Range(0, 20)) = 0
		_AlphaCutoff("Alpha Cutoff", Range(0, 1)) = 0.5
		[NoScaleOffset] _NormalMap("Normal Map", 2D) = "gray" {}
		_BumpScale("Bump Scale", Float) = 0
		[Toggle(_BINORMAL_PER_FRAGMENT)]_BinormalPerFragment("Binormal Per Fragment", Int) = 0
		_MetallicMap("Metallic (R) Smoothness (A)", 2D) = "white" {}
		_MetallicStrength("Metallic", Range(0, 1)) = 0
		_SmoothnessStrength("Smoothness", Range(0, 1)) = 0
		[Toggle(_FORCE_BOX_PROJECTION)]_ForceBoxProjection("Force Box Projection", Int) = 0
		_OcclusionMap("Ambient Occlusion (G)", 2D) = "white" {}
		_OcclusionStrength("AO Strength", Range(0, 1)) = 1
		_ParallaxMap("Height Map (B)", 2D) = "black" {}
		_ParallaxStrength("Parallax Strength", Range(0, 1)) = 0
		_ParallaxDepth("Parallax Depth", Range(0, 10)) = 1
		[Toggle(_PARALLAX_RAYMARCHING)]_UseParallaxRaymarching("Use Parallax Raymarching", Int) = 0
		[IntRange] _ParallaxRaymarchingSteps("Parallax Raymarching Steps", Range(1, 100)) = 10
		_EmissionColor("Emission Tint", Color) = (1, 1, 1, 1)
		_EmissionMap("Emission (RGB)", 2D) = "white" {}
		_EmissionStrength("Emission Strength", Range(0, 1)) = 0

		_DefaultSection("Default Section", Vector) = (0, 0, 1, 1)
		_Section1("Section 1", Vector) = (0, 0, 1, 1)
		_Section2("Section 2", Vector) = (0, 0, 1, 1)
		_Section3("Section 3", Vector) = (0, 0, 1, 1)
		_Section4("Section 4", Vector) = (0, 0, 1, 1)
		_Section5("Section 5", Vector) = (0, 0, 1, 1)
		_Section6("Section 6", Vector) = (0, 0, 1, 1)
		_Section7("Section 7", Vector) = (0, 0, 1, 1)
		_Section8("Section 8", Vector) = (0, 0, 1, 1)
		_Section9("Section 9", Vector) = (0, 0, 1, 1)
		_Section10("Section 10", Vector) = (0, 0, 1, 1)
		_Section11("Section 11", Vector) = (0, 0, 1, 1)
		_Section12("Section 12", Vector) = (0, 0, 1, 1)
		_Section13("Section 13", Vector) = (0, 0, 1, 1)
		_Section14("Section 14", Vector) = (0, 0, 1, 1)
		_Section15("Section 15", Vector) = (0, 0, 1, 1)
		_Section16("Section 16", Vector) = (0, 0, 1, 1)
		_Section17("Section 17", Vector) = (0, 0, 1, 1)
		_Section18("Section 18", Vector) = (0, 0, 1, 1)
		_Section19("Section 19", Vector) = (0, 0, 1, 1)
		_Section20("Section 20", Vector) = (0, 0, 1, 1)
		_Section21("Section 21", Vector) = (0, 0, 1, 1)
		_Section22("Section 22", Vector) = (0, 0, 1, 1)
		_Section23("Section 23", Vector) = (0, 0, 1, 1)
		_Section24("Section 24", Vector) = (0, 0, 1, 1)
		_Section25("Section 25", Vector) = (0, 0, 1, 1)
		_Section26("Section 26", Vector) = (0, 0, 1, 1)
		_Section27("Section 27", Vector) = (0, 0, 1, 1)
		_Section28("Section 28", Vector) = (0, 0, 1, 1)
		_Section29("Section 29", Vector) = (0, 0, 1, 1)
		_Section30("Section 30", Vector) = (0, 0, 1, 1)
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" }

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			Blend One OneMinusSrcAlpha

			CGPROGRAM

			#pragma target 3.0

			#pragma multi_compile_fwdbase
			#pragma multi_compile _ _PARALLAX_RAYMARCHING
			#pragma multi_compile _ _BINORMAL_PER_FRAGMENT
			#pragma multi_compile _ _FORCE_BOX_PROJECTION

			#pragma vertex vert
			#pragma fragment frag

			#define FORWARD_BASE_PASS

			#include "Lighting.cginc"

			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }

			Blend SrcAlpha One

			ZWrite Off

			CGPROGRAM

			#pragma target 3.0

			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile _ _PARALLAX_RAYMARCHING
			#pragma multi_compile _ _BINORMAL_PER_FRAGMENT

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ShadowCaster" }

			CGPROGRAM

			#pragma target 3.0

			#pragma multi_compile_shadowcaster

			#pragma vertex vert
			#pragma fragment frag

			#include "Shadows.cginc"

			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "Meta" }

			Cull Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lightmapping.cginc"

			ENDCG
		}
	}
}
