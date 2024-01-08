#if !defined(MY_SHADOWS_INCLUDED)
#define MY_SHADOWS_INCLUDED

#include "UnityCG.cginc"
#include "Structs.cginc"

#if defined(SHADOWS_CUBE)
	Shadows_v2f vert(Shadows_appdata v)
	{
		Shadows_v2f o;
		o.position = UnityObjectToClipPos(v.position);
		o.lightVec = mul(unity_ObjectToWorld, v.position).xyz - _LightPositionRange.xyz;
		return o;
	}

	float4 frag(Shadows_v2f i) : SV_TARGET
	{
		float depth = length(i.lightVec) + unity_LightShadowBias.x;
		depth *= _LightPositionRange.w;
		return UnityEncodeCubeShadowDepth(depth);
	}
#else
	float4 vert(Shadows_appdata v) : SV_POSITION
	{
		float4 position = UnityClipSpaceShadowCasterPos(v.position.xyz, v.normal);
		return UnityApplyLinearShadowBias(position);
	}

	half4 frag() : SV_TARGET
	{
		return 0;
	}
#endif

#endif
