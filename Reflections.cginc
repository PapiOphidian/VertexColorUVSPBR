#if !defined(MY_REFLECTIONS_INCLUDED)
#define MY_REFLECTIONS_INCLUDED

float3 BoxProjection(
	float3 direction, float3 position,
	float4 cubemapPosition, float3 boxMin, float3 boxMax)
{
	#if defined(UNITY_SPECCUBE_BOX_PROJECTION) && !defined(UNITY_PBS_USE_BRDF2) || defined(_FORCE_BOX_PROJECTION)
		UNITY_BRANCH
		if (cubemapPosition.w > 0)
		{
			float3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
			float scalar = min(min(factors.x, factors.y), factors.z);
			direction = direction * scalar + (position - cubemapPosition.xyz);
		}
	#endif
	return direction;
}
#endif
