//////////////////////////////////////////////////////////////////////////////
//
// Global constants
//
// All constants used by hlsl files must be defined globally here, ensuring
// no overlaps of register usage and enusring consistency across all shader
// implementations.
//
//
//////////////////////////////////////////////////////////////////////////////

// Ensure that we always use column major packing
#pragma pack_matrix( col_major )

//////////////////////////////////////////////////////////////////////////////
// Defines

#define	 MAX_MATS				72
#define  MAX_LITS				32


//////////////////////////////////////////////////////////////////////////////
// Normal-map-related defines

#define TWO_CHANNEL_NORMAL_MAPS 0
#define DXDY_NORMAL_MAPS 0

// Define which channels the normal map data resides in
#if TWO_CHANNEL_NORMAL_MAPS && !XBOX
#define NORMAL_MAP_CHANNELS agrb // rb is unused
#else
#define NORMAL_MAP_CHANNELS rgba // ba is unused in two-channel mode
#endif

// Default value for packed normal data, represents "up" in tangent space
#define DEFAULT_PACKED_NORMAL_DATA float4( 0.5f, 0.5f, 1.0f, 1.0f )


//////////////////////////////////////////////////////////////////////////////
// Shared shader constants
// - These may not overlap with constants from vertex or pixel shaders, and 
//   must reside in unique registers to both pools.

float    Time					: register( c0 );	// The time as tracked by the game for this frame
float3   ViewDirection			: register( c1 );	// The view direction in world space
float3   ViewPosition			: register( c2 );	// The view position in world space
float4	 SunDirection			: register( c3 );	// The prevailing (sun) light direction in world space
float4	 FogIntel				: register( c4 );	// The fog/intel uv scalar in xy, fixed fog width in z


//////////////////////////////////////////////////////////////////////////////
// Vertex shader constants
// - These may overlap with pixel shader constants, but they must not overlap
//   with each other.  You must specify register usage with each constant.

float3   TransposeViewX			: register( c5 );	// The transpose of the X basis of the view matrix
float3   TransposeViewY			: register( c6 );	// The transpose of the Y basis of the view matrix
float4x4 ViewProj				: register( c7 );	// The view/proj matrix
float4x4 Shadow					: register( c11 );	// The shadow matrix
float4   ShadowDepth			: register( c15 );	// The Z column of the light view/proj matrix used for shadow calcs
float4   OrthoDepth				: register( c16 );	// The Z column of the orthographic view/proj matrix used for depth calcs
float	 VertsPerInstance		: register( c17 );	// The number of vertices per instance, used for Xbox 360 instancing
float4   LightPosDist			: register( c18 );	// The dynamic light position in xyz and reciprocal of light distance in w
float3   MapCenter				: register( c19 );	// The center coordinate of the current map
float2   ScreenTexOffset		: register( c20 );	// The offset value to apply to texture coordinates when sampling screen textures
float2   TextureScroll			: register( c21 );	// The UV scrolling offsets
float3   WindDirection			: register( c22 );	// The wind direction in xy and the wind speed in z

// Support for 72 arbitrary transforms
float4x3 Matrices[MAX_MATS]		: register( c23 );	// Instance/Bone transforms


//////////////////////////////////////////////////////////////////////////////
// Pixel shader constants
// - These may overlap with vertex shader constants, but they must not overlap
//   with each other.  You must specify register usage with each constant.

float4	 ShadowColor			: register( c5 );	// The color of ambient/shadowed areas
float3	 SunColor				: register( c6 );	// The prevailing (sun) light color
float4	 GlobalColor			: register( c7 );	// The global color used for various purposes
float4   TeamColor1				: register( c8 );	// The first team color
float4   TeamColor2				: register( c9 );	// The second team color
float4   FogColor				: register( c10 );	// The fog color
float3   FogAmounts				: register( c11 );	// The fog amounts, ambient in x, near in y, far in z
float3   FogDistances			: register( c12 );	// The fog distances, near dist in x, 1/near dist in y, 1/(far dist - near dist) in z
float3   WaterDiffuse1Movement	: register( c13 );	// The movement of the first foam map
float3   WaterDiffuse2Movement  : register( c14 );	// The movement of the second foam map
float3   WaterNormal1Movement	: register( c15 );	// The movement of the first water normal map
float3   WaterNormal2Movement	: register( c16 );	// The movement of the second water normal map
float3   WaterNormal3Movement	: register( c17 );	// The movement of the third water normal map
float3   WaterNormal4Movement	: register( c18 );	// The movement of the fourth water normal map
float4	 WaterColor				: register( c19 );	// The color of the water
float4   WaterScales			: register( c20 );	// The refraction scale, reflection scale, depth scale, and chromatic scale
float4   WaterLighting			: register( c21 );	// The fresnel bias and power for water in xy, the spec power and bloom factor in zw
float4   WaterDepth				: register( c22 );	// The water depth area position and scale
float3	 WaterWhiteCap			: register( c23 );	// The whitecap cutoff, brightness, and foam depth
float4   WaterWaves				: register( c24 );	// The wave start factor and inverse, wave timing and time modulus
float3   PointCloudPos			: register( c25 );	// The point cloud position in world space
float3	 PointCloudScale		: register( c26 );	// The point cloud scalar that take world position into UVW texture coords
float3   PointCloudLightAmount	: register( c27 );	// The amount of light that should be added to each unit from the point cloud
float2	 BloomValues			: register( c28 );	// The bloom value threshold value for clamped bloom effects in x, the averaging multiplier in y
float2	 DepthOfFieldValues		: register( c29 );	// The depth of field ranges
float4   SharpenValues			: register( c30 );	// The image sharpening values
float4   FogOfWarHeightValues   : register( c31 );  // The fog of war height blending values
float4   IntelHeightValues      : register( c32 );  // The intel height blending values
float4	 GaussianSamples[16]	: register( c33 );	// Sampling weights for gaussian filter
float4   LightDirRamp[MAX_LITS]	: register( c49 );	// Light directions (in xyz) and v ramp offsets (in w)



//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//
// Global functions
//
// Any functions that are of use across multiple hlsl files can be defined
// here.  This should include any formulae that should remain consistent
// across all implementations of a technique throughout the pipeline.
//
//
//////////////////////////////////////////////////////////////////////////////

float4 SmoothCurve( float4 x )
{
	return( x * x * (3.0f - (2.0f * x)) );
}

float4 TriangleWave( float4 x )
{
	return( abs( frac( x + 0.5f ) * 2.0f - 1.0f ) );
}

float4 SmoothTriangleWave( float4 x )
{
	return( SmoothCurve( TriangleWave( x ) ) );
}

float Lambert( float3 nlight, float3 normal )
{
	return( max( 0.000001f, dot( nlight, normal ) ) );
}

float HalfLambert( float3 nlight, float3 normal )
{
	float scaledLambert	= dot( nlight, normal ) * 0.5f + 0.5f;
	return( scaledLambert * scaledLambert );
}

float3 DiffuseFormula( float3 dColor, float3 nlight, float3 normal,
					   uniform sampler2D RampSampler, uniform float RampOffset )
{
#if DIFFUSE_LIGHTING
#if RAMP_MAP
	return( dColor * tex2D( RampSampler, float2( Lambert( nlight, normal ), RampOffset ) ).rgb );
#else
	return( dColor * Lambert( nlight, normal ) );
#endif
#else
	return( float3( 0.0f, 0.0f, 0.0f ) );
#endif
}

float3 DiffuseHalfLambertFormula( float3 dColor, float3 nlight, float3 normal,
								  uniform sampler2D RampSampler, uniform float RampOffset )
{
#if DIFFUSE_LIGHTING
#if RAMP_MAP
	return( dColor * tex2D( RampSampler, float2( HalfLambert( nlight, normal ), RampOffset ) ).rgb );
#else
	return( dColor * HalfLambert( nlight, normal ) );
#endif
#else
	return( float3( 0.0f, 0.0f, 0.0f ) );
#endif
}

float3 SpecularFormula( float3 sColor, float3 nlight, float3 reflView,
						uniform sampler2D RampSampler, uniform float RampOffset )
{
#if SPECULAR_LIGHTING
#if RAMP_MAP
	return( sColor * tex2D( RampSampler, float2( Lambert( nlight, reflView ), RampOffset ) ).rgb );
#else
	return( sColor * pow( Lambert( nlight, reflView ), 20 ) );
#endif
#else
	return( float3( 0.0f, 0.0f, 0.0f ) );
#endif
}

// Compute the light contribution from this light source
float3 ComputeLight( float3 nlight, float3 normal, float3 reflView,
					 float3 lightColor, float3 diffuseColor, float specLevel,
					 uniform sampler2D RampSampler, uniform float DiffuseRampOffset, uniform float SpecularRampOffset )
{
	return( DiffuseFormula( lightColor * diffuseColor.rgb, nlight, normal, RampSampler, DiffuseRampOffset ) +
			SpecularFormula( lightColor * specLevel, nlight, reflView, RampSampler, SpecularRampOffset ) );
}

// Compute the light contribution from this spot light source
float3 ComputeSpotLight( float3 nlight, float4 lightDir, float3 normal, float3 reflView,
						 float3 diffuseColor, float specLevel, float atten,
						 uniform sampler2D LightRampSampler, uniform sampler2D RampSampler,
						 uniform float DiffuseRampOffset, uniform float SpecularRampOffset )
{
	// Get the light ramp value from the composite light ramp map
	float3 lightRamp	= tex2D( LightRampSampler, float2( (dot( lightDir.xyz, nlight ) * 0.5) + 0.5, lightDir.w ) ).rgb * atten;
	
	// Compute the light
	return( ComputeLight( nlight, normal, reflView,
						  lightRamp, diffuseColor, specLevel,
						  RampSampler, DiffuseRampOffset, SpecularRampOffset ) );
}

// Compute the environment contribution
float3 ComputeEnvironment( float3 normal, float3 reflView, float envLevel,
						   uniform sampler2D RampSampler, uniform samplerCUBE EnvironmentSampler, uniform float EnvironmentRampOffset )
{
#if RAMP_MAP
	return( texCUBE( EnvironmentSampler, reflView ).rgb *
			(tex2D( RampSampler, float2( dot( -ViewDirection, normal ), EnvironmentRampOffset ) ).rgb * envLevel) );
#else
	return( float3( 0.0f, 0.0f, 0.0f ) );
#endif	
}

// Compute the shadow amount by looking up the shadow map depth
float ComputeShadow( float4 shadowCoord,
					 uniform sampler2D ShadowSampler )
{
#if !defined( SHADOW_QUALITY ) || SHADOW_QUALITY == 0
	return 1.0f;
#else
	float shadowValue	= 0.0f;

#if XBOX

	shadowCoord.xyz		/= shadowCoord.w;
	shadowCoord.z		= min( shadowCoord.z, 0.999f );
	float4 filterWeights;
	float4 shadowValues;
	float LOD;	

	float2 offCoord	= shadowCoord.xy;
	asm
	{
#ifdef SHADOW_MIPS
		getCompTexLOD2D LOD.x, offCoord.xy, ShadowSampler, AnisoFilter = max16to1
		setTexLOD LOD.x

		tfetch2D shadowValues.x___, offCoord.xy, ShadowSampler, OffsetX = -0.5, OffsetY = -0.5, UseComputedLOD=false, UseRegisterLOD=true
		tfetch2D shadowValues._x__, offCoord.xy, ShadowSampler, OffsetX =  0.5, OffsetY = -0.5, UseComputedLOD=false, UseRegisterLOD=true
		tfetch2D shadowValues.__x_, offCoord.xy, ShadowSampler, OffsetX = -0.5, OffsetY =  0.5, UseComputedLOD=false, UseRegisterLOD=true
		tfetch2D shadowValues.___x, offCoord.xy, ShadowSampler, OffsetX =  0.5, OffsetY =  0.5, UseComputedLOD=false, UseRegisterLOD=true

		getWeights2D filterWeights, offCoord.xy, ShadowSampler, MagFilter = linear, MinFilter = linear, UseComputedLOD=false, UseRegisterLOD=true
#else
		tfetch2D shadowValues.x___, offCoord.xy, ShadowSampler, OffsetX = -0.5, OffsetY = -0.5, MagFilter = point, MinFilter = point
		tfetch2D shadowValues._x__, offCoord.xy, ShadowSampler, OffsetX =  0.5, OffsetY = -0.5, MagFilter = point, MinFilter = point
		tfetch2D shadowValues.__x_, offCoord.xy, ShadowSampler, OffsetX = -0.5, OffsetY =  0.5, MagFilter = point, MinFilter = point
		tfetch2D shadowValues.___x, offCoord.xy, ShadowSampler, OffsetX =  0.5, OffsetY =  0.5, MagFilter = point, MinFilter = point

		getWeights2D filterWeights, offCoord.xy, ShadowSampler, MagFilter = linear, MinFilter = linear
#endif
	};
	
	filterWeights	= float4( (1-filterWeights.x)*(1-filterWeights.y), filterWeights.x*(1-filterWeights.y), (1-filterWeights.x)*filterWeights.y, filterWeights.x*filterWeights.y );
	float4 atten	= step( shadowCoord.z, shadowValues );

	shadowValue		+= dot( atten, filterWeights );	
	return shadowValue;

#else

	for( int i = 0; i < 4; ++i )
	{
#if SHADOW_COLOR_OUTPUT
		shadowValue		+= tex2Dproj( ShadowSampler, float4( shadowCoord.xy + GaussianSamples[i].xy * shadowCoord.w, shadowCoord.zw ) ).r < shadowCoord.z ? 0.0f : 1.0f;
#else
		shadowValue		+= tex2Dproj( ShadowSampler, float4( shadowCoord.xy + GaussianSamples[i].xy * shadowCoord.w, shadowCoord.zw ) ).r;
#endif
	}

	return( shadowValue * 0.25f );
#endif

#endif
}

// Compute the fog amount by linearly interpolating the values based on distance from the camera
float ComputeFog( float3 viewVec )
{
	float viewDist		= length( viewVec );
	return( lerp( lerp( FogAmounts.x, FogAmounts.y, saturate( viewDist * FogDistances.y ) ), FogAmounts.z, saturate( (viewDist - FogDistances.x) * FogDistances.z ) ) );
}

// Compute the output color
float4 ComputeOutColor( float4 outColor, float3 fogVector, float3 fogColor )
{
#if GLOW && !DYNAMIC_LIGHT
	return lerp( outColor, float4( fogColor.rgb, 0.0f ), ComputeFog( fogVector ) );
#else
	return float4( lerp( outColor.rgb, fogColor.rgb, ComputeFog( fogVector ) ), outColor.a );
#endif
}

// Compute a final normal vector from either a packed normal vector or packed dxdy data
float3 ComputeNormalVectorFromPackedNormalData( float3 normal )
{
	// Unpack
	normal = normal * 2.0f - 1.0f;

	// Compute z or convert from dxdy to vector
#if TWO_CHANNEL_NORMAL_MAPS
#if DXDY_NORMAL_MAPS	
	normal = normalize( float3(-normal.x, -normal.y, 1.0f) );
#else
	normal.z = sqrt( saturate( 1.0f - dot( normal.xy, normal.xy ) ) );
#endif	
#endif
	return normal;
}

// Compute screen texture coordinates by doing appropriate scale and biasing
float2 ComputeScreenCoords( float4 screenCoord )
{
	return( float2( (screenCoord.x + screenCoord.w) * 0.5f, (-screenCoord.y + screenCoord.w) * 0.5f ) + (ScreenTexOffset * screenCoord.ww) );
}
