layout (location = 0) in vec3 inPos;
layout (location = 1) in vec3 inNorm;
layout (location = 2) in vec3 inTan;
layout (location = 3) in vec3 inBiNorm;
layout (location = 6) in vec2 inUV0;

#ifdef SOB_BADGE
layout (location = 7) in vec2 inUV1;
smooth out vec2 outUV1;
#endif

#ifdef SOB_RESOURCE

uniform vec2 inFadeInfo;
uniform vec4 inTime;

#ifdef SOB_DUALINPUT
// UVs for empty/full by surface
smooth out vec2 outUV_Diff0;
smooth out vec2 outUV_Glow0;
smooth out vec2 outUV_Spec0;
smooth out vec2 outUV_Norm0;
smooth out vec2 outUV_Diff1;
smooth out vec2 outUV_Glow1;
smooth out vec2 outUV_Spec1;
smooth out vec2 outUV_Norm1;
uniform vec4 inGridDiff;
uniform vec4 inGridGlow;
uniform vec4 inGridSpec;
uniform vec4 inGridNorm;
#endif

#endif

uniform mat4 inMatM;
uniform mat4 inMatV;
uniform mat4 inMatP;

#ifdef SOB_SHADOWS_ON
	uniform mat4 inMatKL;
	uniform vec4 inShadowTrans[4];
	smooth out vec3 outPos_KL;
	
	#ifdef SOB_SHADOWS_DUAL
		uniform mat4 inMatFL;
		smooth out vec3 outPos_FL;
	#endif

#endif

#ifdef SOB_USECLIP
uniform vec4 inClipPlane;
#endif

uniform vec4 inTime;
uniform vec4 inAnimParams;

smooth out vec2 outUV0;
smooth out vec3 outNorm;
smooth out vec3 outTan;
smooth out vec3 outBiNorm;
smooth out vec3 outPos_W;
smooth out vec3 outEye_W;

void main()
{
#ifdef SOB_DUALINPUT
	// UVs for empty/full by surface
	outUV_Diff0 = inUV0*inGridDiff.xy;
	outUV_Diff1 = outUV_Diff0+vec2(inGridDiff.z, inGridDiff.w);
	outUV_Glow0 = inUV0*inGridGlow.xy;
	outUV_Glow1 = outUV_Glow0+vec2(inGridGlow.z, inGridGlow.w);
	outUV_Spec0 = inUV0*inGridSpec.xy;
	outUV_Spec1 = outUV_Spec0+vec2(inGridSpec.z, inGridSpec.w);
	outUV_Norm0 = inUV0*inGridNorm.xy;
	outUV_Norm1 = outUV_Norm0+vec2(inGridNorm.z, inGridNorm.w);
#endif

	vec4 usePos = vec4(inPos, 1.0);

	mat4 invV = inverse(inMatV);
	vec4 posW4 = inMatM*usePos;
	outPos_W = posW4.xyz;
	outEye_W = outPos_W-invV[3].xyz;	// World-space for reflections/etc
	
#ifdef SOB_SHADOWS_ON
	vec3 posL = (inMatKL*posW4).xyz;
	vec3 litBuf = (posL*inShadowTrans[1].xyz)+inShadowTrans[0].xyz;
	outPos_KL = litBuf;
	
	#ifdef SOB_SHADOWS_DUAL
		posL = (inMatFL*posW4).xyz;
		litBuf = (posL*inShadowTrans[3].xyz)+inShadowTrans[2].xyz;
		outPos_FL = litBuf;
	#endif

#endif
	
	outNorm = inNorm;
	outTan = inTan;
	outBiNorm = inBiNorm;
	outUV0 = inUV0;
	
	// CMDBob: UV animation
	
	int type = int(inAnimParams.w);
	
	// flipbook
	if (type == 0)
	{
	// calculate how far the UV coordinates are to be shifted
	float uvcoordinateX = 1.0 / inAnimParams.x;
	float uvcoordinateY = -(1.0 / inAnimParams.y);
	
	// calculate the timestep.
	float timestep = inTime.x * inAnimParams.z;
	
	// work out where in the sequnce we are. floor it so it doesn't give us decimals and always rounds down.
	float uvX = floor(mod(timestep , inAnimParams.x));
	float uvY = floor(timestep / inAnimParams.y);
	
	// calculate final uv coordinates.
	outUV0.x = inUV0.x + mod((uvcoordinateX * uvX),1);
	outUV0.y = inUV0.y + mod((uvcoordinateY * uvY),1);
	}
	
	// scrolling/rotating
	if (type == 1)
	{
	// generate the rotation angle
	float rotationAngle = (inTime.x * inAnimParams.z) / 10;
	
	// define rotation matrix
	mat2 UVRotationMatrix = mat2( cos(rotationAngle), sin(rotationAngle),
								-sin(rotationAngle), cos(rotationAngle));
								
	// calculate rotated UVs
	outUV0 = inUV0 - vec2(0.5, 0.5);
	outUV0 = UVRotationMatrix * outUV0;
	outUV0 = outUV0 + vec2(0.5, 0.5);
	
	// scrolling
	outUV0.x = outUV0.x + (inTime.x * inAnimParams.x / 10);
	outUV0.y = outUV0.y + (inTime.x * inAnimParams.y / 10);
	

	
	}
	
#ifdef SOB_BADGE
	outUV1 = inUV1;
#endif
	
	mat4 VP = inMatP*inMatV;
	gl_Position = VP*posW4;			// Clip-space vert for geo/rasterize
	
#ifdef SOB_USECLIP
	gl_ClipDistance[0] = dot(inClipPlane, vec4(outPos_W, 1.0));
#endif
}
