#if !defined(MY_PARALLAX_INCLUDED)
#define MY_PARALLAX_INCLUDED

#if defined(_PARALLAX_RAYMARCHING)
	#define PARALLAX_FUNCTION ParallaxRaymarching
#endif

float _ParallaxRaymarchingSteps;
float _ParallaxDepth;

float2 ParallaxOffset(float2 section, float2 viewDir, float2 uv) {
	float height = GetParallaxHeight(section, uv);
	if (height == 0) return float2(0, 0);
	height -= _ParallaxDepth;
	height *= _ParallaxStrength;
	return viewDir * height;
}

float2 ParallaxRaymarching(float2 section, float2 viewDir, float2 uv) {
	float surfaceHeight = GetParallaxHeight(section, uv);
	if (surfaceHeight == 0) return float2(0, 0);
	float2 uvOffset = 0;
	float stepSize = 1 / _ParallaxRaymarchingSteps;
	float2 uvDelta = viewDir * (stepSize * _ParallaxStrength);
	float stepHeight = _ParallaxDepth;
	float2 prevUVOffset = uvOffset;
	float prevStepHeight = stepHeight;
	float prevSurfaceHeight = surfaceHeight;

	[loop]
	for (int i = 1; i < _ParallaxRaymarchingSteps && stepHeight > surfaceHeight; i++) {
		prevUVOffset = uvOffset;
		prevStepHeight = stepHeight;
		prevSurfaceHeight = surfaceHeight;
		uvOffset -= uvDelta;
		stepHeight -= stepSize;
		surfaceHeight = GetParallaxHeight(section + uvOffset, uv + uvOffset);
	}

	float prevDifference = prevStepHeight - prevSurfaceHeight;
	float difference = surfaceHeight - stepHeight;
	float t = prevDifference / (prevDifference + difference);
	return prevUVOffset - uvDelta * t;
}

void ApplyParallax(inout Lighting_v2f i, inout float2 section) {
	#if !defined(PARALLAX_FUNCTION)
		#define PARALLAX_FUNCTION ParallaxOffset
	#endif
	float2 uvOffset = PARALLAX_FUNCTION(section, i.tangentViewDir.xy, i.uv.xy);
	section.xy += uvOffset;
}
#endif
