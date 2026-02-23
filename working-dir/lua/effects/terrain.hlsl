//////////////////////////////////////////////////////////////////////////////
//
// Global constants are defined in global_constants.hlsl
//
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Textures/Samplers used by this shader

// Samplers that come from source material art
sampler2D   Diffuse1Map;
sampler2D   Normal1Map;
sampler2D   Diffuse2Map;
sampler2D   Normal2Map;
sampler2D	Mask1Map;
sampler2D	Mask2Map;
sampler2D	RampMap;
sampler2D	DetailNormalsMap;

// Samplers that come from generated lighting
sampler2D	RNMSlice0Map;
sampler2D	RNMSlice1Map;
sampler2D	RNMSlice2Map;

// Samplers that come from source map art
samplerCUBE EnvironmentMap;
sampler2D	LightRampMap;

// Screen textures for decal overlay
sampler2D	DecalDiffuseMap;
sampler2D	DecalNormalMap;

// Sampler for the shadow map
sampler2D	ShadowMap;

// Sampler for the fog of war map
sampler2D	FogIntelMap;


//////////////////////////////////////////////////////////////////////////////
// Ramp texel offsets
#define		RampMapHeight					8.0f
#define		DiffuseRampOffset				0.5f / RampMapHeight
#define		SpecularRampOffset				1.5f / RampMapHeight
#define		EnvironmentRampOffset			2.5f / RampMapHeight


//////////////////////////////////////////////////////////////////////////////
// Utility functions

// Compute direct+indirect illumination at a point with a given normal using the 3 RNM textures
float3 ComputeRNM( float3 normal, float3 c0, float3 c1, float3 c2 )
{
    // $$ temporary - use the "old" (non-ssbump) method - normal is in tangent space, dot with HL2 RNM basis vectors
    // $$ to get contribution from each RNM texture
    // The first RNM has a sun occlusion factor (or 1.0f) in its alpha component
    float3 dp;
    dp.x = saturate( dot( normal, float3( 0.81649658092772615,  0,                   0.57735026918962584) ) );
    dp.y = saturate( dot( normal, float3(-0.40824829046386307,  0.70710678118654746, 0.57735026918962584) ) );
    dp.z = saturate( dot( normal, float3(-0.40824829046386307, -0.70710678118654746, 0.57735026918962584) ) );
    //dp *= dp;
    //float sum = dot( dp, float3( 1, 1, 1 ) );
    float3 col = dp.x * c0 + dp.y * c1 + dp.z * c2;
    //col /= sum;
    return col;
}


//////////////////////////////////////////////////////////////////////////////
// Vertex input/output definitions

struct VS_INPUT
{
	float3 Position			: POSITION0;	// Contains static vertex position
	float2 TexCoordLocal	: TEXCOORD0;	// Contains static vertex texture coordinate set 1 (diffuse, normal, etc)
	
#if !Z_PASS
	float2 TexCoordGlobal	: TEXCOORD1;	// Contains static vertex texture coordinate set 2 (RNM)	
	float3 Normal			: NORMAL;		// Contains static vertex normal
	float3 Tangent			: TANGENT;		// Contains static vertex tangent
	float3 BiNormal			: BINORMAL;		// Contains static vertex binormal
#elif ALPHA_TEST
	float2 TexCoordGlobal	: TEXCOORD1;	// Contains static vertex texture coordinate set 2 (RNM)
#endif
};

#if Z_PASS

struct VS_OUTPUT
{
	float4 Position			: POSITION;		// Contains vertex shader output position, not used in pixel shader
#ifdef ALPHA_TEST
	float4 TexCoord			: TEXCOORD0;	// Contains texture coordinates (xy is local, zw is global)
#endif
#if DEPTH_OUT
	float Depth				: TEXCOORD1;	// Contains the linear normalized depth
#endif
#if FOGOFWAR_OUT
	float3 WorldPos			: TEXCOORD2;	// Contains the world space position transformed into fog uv space
#endif
};

#else

struct VS_OUTPUT
{
	float4 Position			: POSITION;		// Contains vertex shader output position, not used in pixel shader	

	float4 TexCoord			: TEXCOORD0;	// Contains texture coordinates (xy is local, zw is global)

	float4 ScreenCoord		: TEXCOORD1;	// Contains the screen coordinate
	float4 ShadowCoord		: TEXCOORD2;	// Contains the shadow coordinate
	
	float3 Normal			: TEXCOORD3;	// Contains the vertex normal in xyz
	float3 Tangent			: TEXCOORD4;	// Contains the vertex tangent in xyz
	float3 BiNormal			: TEXCOORD5;	// Contains the vertex binormal in xyz
	
	float3 WorldPos			: TEXCOORD6;	// Contains world space position in xyz
#if DYNAMIC_LIGHT
	float3 LightVec			: TEXCOORD7;	// The light vector in world space with the light intensity
#endif
};

#endif


//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VS_OUTPUT TerrainVS( VS_INPUT In )
{
	// Output from vertex shader
	VS_OUTPUT Out			= (VS_OUTPUT)0;

	// Build output position
#if INFINITE_DISTANCE
	Out.Position			= mul( float4( (In.Position.xyz - MapCenter) + ViewPosition, 1 ), ViewProj );
#else
	Out.Position			= mul( float4( In.Position.xyz, 1 ), ViewProj );
#endif

	// During any z pass, we need to keep normalized linear depth	
#if Z_PASS
#if DEPTH_OUT
	Out.Depth				= dot( float4( In.Position.xyz, 1 ), OrthoDepth );
#endif

#if FOGOFWAR_OUT
	Out.WorldPos			= In.Position.xyz;
#endif
	
#ifdef ALPHA_TEST
	// Build texture coordinates
	Out.TexCoord			= float4( In.TexCoordLocal + (TextureScroll * Time), In.TexCoordGlobal );
#endif

	return Out;
#else

	// Build texture coordinates
	Out.TexCoord			= float4( In.TexCoordLocal + (TextureScroll * Time), In.TexCoordGlobal );

	// Build screen output coordinates
	Out.ScreenCoord			= float4( ComputeScreenCoords( Out.Position ), Out.Position.zw );
	
	// Build shadow output coordinates
	Out.ShadowCoord			= mul( float4( In.Position.xyz, 1 ), Shadow );
#if SHADOW_COLOR_OUTPUT
	Out.ShadowCoord.z		= min( 0.999f, dot( float4( In.Position.xyz, 1 ), ShadowDepth ) );
#endif	

	// Transfer tangent basis to pixel shader
	Out.Normal				= In.Normal;
	Out.Tangent				= In.Tangent;
	Out.BiNormal			= In.BiNormal;
	
	// View vector for reflect calculations
	Out.WorldPos			= In.Position.xyz;

	// Build light information for dynamic light
#if DYNAMIC_LIGHT
	Out.LightVec			= (LightPosDist.xyz - In.Position.xyz) * LightPosDist.w;
#endif

	// Return our finished product
	return Out;
#endif
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 TerrainPS( VS_OUTPUT In ) : COLOR
{
#if Z_PASS && !defined( ALPHA_TEST )
	float4 result			= float4( 0.0f, 0.0f, 0.0f, 0.0f );
#if DEPTH_OUT
	result.r				= In.Depth;
#endif
#if FOGOFWAR_OUT
	result.g				= tex2D( FogIntelMap, In.WorldPos.xz * FogIntel.xy ).a *
							  (1.0f - saturate( (abs( In.WorldPos.y - FogOfWarHeightValues.x ) - FogOfWarHeightValues.y) * FogOfWarHeightValues.z ));
#endif
	return result;
#else

	// Calculate dynamic light attenuation and clip pixel if it cannot contribute
#if DYNAMIC_LIGHT
	float atten				= 1 - dot( In.LightVec.xyz, In.LightVec.xyz );
	clip( atten );
#endif

	// Sample our texture maps using our texture coordinates
#if DIFFUSE1_MAP
	float4 diffuse1Color	= tex2D( Diffuse1Map, In.TexCoord.xy );
#else
	float4 diffuse1Color	= float4( 1.0f, 1.0f, 1.0f, 1.0f );
#endif

#if NORMAL1_MAP
	float4 normal1Color		= tex2D( Normal1Map, In.TexCoord.xy ).NORMAL_MAP_CHANNELS;
#else
	float4 normal1Color		= DEFAULT_PACKED_NORMAL_DATA;
#endif

#if DIFFUSE2_MAP
	float4 diffuse2Color	= tex2D( Diffuse2Map, In.TexCoord.xy );
#else
	float4 diffuse2Color	= float4( 1.0f, 1.0f, 1.0f, 1.0f );
#endif

#if NORMAL2_MAP
	float4 normal2Color		= tex2D( Normal2Map, In.TexCoord.xy ).NORMAL_MAP_CHANNELS;
#else
	float4 normal2Color		= DEFAULT_PACKED_NORMAL_DATA;
#endif

#if RNM_LIGHTING || BLENDING
	float4 rnm0_soColor     = tex2D( RNMSlice0Map, In.TexCoord.zw );
	float4 rnm1_blendColor  = tex2D( RNMSlice1Map, In.TexCoord.zw );
	float4 rnm2Color        = tex2D( RNMSlice2Map, In.TexCoord.zw );
#else
	float4 rnm0_soColor     = float4( 1.0f, 1.0f, 1.0f, 0.0f );
	float4 rnm1_blendColor  = float4( 1.0f, 1.0f, 1.0f, 0.0f );
	float4 rnm2Color        = float4( 1.0f, 1.0f, 1.0f, 1.0f );
#endif
	float sunOcclusion      = rnm0_soColor.a;

#if BLENDING
	float blendFactor       = rnm1_blendColor.a;
#else
	float blendFactor       = 0.0f;
#endif

	// Calculate the blended diffuse color
#if DIFFUSE2_MAP
	float4 diffuseColor		= lerp( diffuse1Color, diffuse2Color, blendFactor );
#else
	float4 diffuseColor		= diffuse1Color;
#endif
	
#ifdef ALPHA_TEST
	clip( (diffuseColor.a * 255.0f) - (ALPHA_TEST + 1) );
#endif
	
	// If this is the z pass, all we need is the normalized linear depth after the clip
#if Z_PASS
	float4 result			= float4( 0.0f, 0.0f, 0.0f, 0.0f );
#if DEPTH_OUT
	result.r				= In.Depth;
#endif
#if FOGOFWAR_OUT
	result.g				= tex2D( FogIntelMap, In.WorldPos.xz * FogIntel.xy ).a *
							  (1.0f - saturate( (abs( In.WorldPos.y - FogOfWarHeightValues.x ) - FogOfWarHeightValues.y) * FogOfWarHeightValues.z ));
#endif
	return result;
#else

	// Calculate the blended normal
#if NORMAL2_MAP
	float3 normal			= lerp( normal1Color, normal2Color, blendFactor ).xyz;
#else
	float3 normal			= normal1Color.xyz;
#endif

#if DECALS
	// Sample the screen texture that represents decal data
	float4 decalDiffuse		= tex2Dproj( DecalDiffuseMap, In.ScreenCoord );
	float4 decalNormal		= tex2Dproj( DecalNormalMap, In.ScreenCoord );

	// Blend the decal data into the current results
	diffuseColor.rgb		= (diffuseColor.rgb * (1.0f - decalDiffuse.a)) + decalDiffuse.rgb;
	normal					= (normal * (1.0f - decalNormal.a)) + decalNormal.rgb;
#endif

	// Add intel overlay into the diffuse color
	float4 intelColor		= tex2D( FogIntelMap, In.WorldPos.xz * FogIntel.xy );
	if( intelColor.a > 0.5f )
	{
		intelColor			*= 1.0f - saturate( (abs( In.WorldPos.y - IntelHeightValues.x ) - IntelHeightValues.y) * IntelHeightValues.z );
		diffuseColor.rgb	= (diffuseColor.rgb * (1.0f - (intelColor.a * FogIntel.w))) + (intelColor.rgb * FogIntel.w);
	}

	// Calculate final normal vector
	normal					= ComputeNormalVectorFromPackedNormalData( normal );

#if MASK1_MAP
	float4 mask1Color		= tex2D( Mask1Map, In.TexCoord.xy );
#else
	float4 mask1Color		= float4( 0.0f, 0.0f, 1.0f, 0.0f );
#endif

#if MASK2_MAP
	float4 mask2Color		= tex2D( Mask2Map, In.TexCoord.xy );
#else
	float4 mask2Color		= float4( 0.0f, 0.0f, 1.0f, 0.0f );
#endif

	// Calculate the blended mask color
#if MASK2_MAP
	float4 maskColor		= lerp( mask1Color, mask2Color, blendFactor );
#else
	float4 maskColor		= mask1Color;
#endif

#if !DYNAMIC_LIGHT
#if GLOW
	diffuseColor.a			= maskColor.g;
#elif !ALPHA_BLEND
	diffuseColor.a			= 0.0f;
#endif
#endif

#if !DYNAMIC_LIGHT && !RNM_LIGHTING
	// Our output color
	float4 OutColor			= diffuseColor;
	
#if AMBIENT_LIGHTING
	// Modulate our ambient/shadow color into the current result
	OutColor.rgb			*= ShadowColor;
#endif
#else
	float4 OutColor			= float4( 0.0f, 0.0f, 0.0f, diffuseColor.a );
#endif
	
    // Save off tangent-space normal for use in RNM lookup
    float3 tsnormal         = normalize( normal );
    
	// Transform the normal from tangent space to world space
	// Note that the normalize here could be removed if the normal map textures were guaranteed normalized
	normal					= normalize( mul( normal, float3x3( In.Tangent.xyz, In.BiNormal.xyz, In.Normal.xyz ) ) );
	
	// Build the reflected view vector for this pixel
	float3 viewVec			= ViewPosition - In.WorldPos.xyz;
	float3 reflView			= -reflect( normalize( viewVec.xyz ), normal );	
	
#if ENVIRONMENT_MAPPING && !DYNAMIC_LIGHT
	// Compute the environment contribution
	OutColor.rgb			+= ComputeEnvironment( normal, reflView, maskColor.r,
												   RampMap, EnvironmentMap, EnvironmentRampOffset );
#endif

	// Process lighting
#if DYNAMIC_LIGHT
	OutColor.rgb			+= ComputeSpotLight( normalize( In.LightVec.xyz ), LightDirRamp[0], normal, reflView,
												 diffuseColor.rgb, maskColor.b, atten,
												 LightRampMap, RampMap,
												 DiffuseRampOffset, SpecularRampOffset );
												 
	// Since this is an additive blend, we need to blend down to black base on the fog calculation
#if FOG
	return ComputeOutColor( OutColor, viewVec.xyz, float3( 0.0f, 0.0f, 0.0f ) );
#else
	return OutColor;
#endif
#elif RNM_LIGHTING
	float3 rnmColor         = ComputeRNM( tsnormal, rnm0_soColor.rgb, rnm1_blendColor.rgb, rnm2Color.rgb );
#if DYNAMIC_SHADOWS
	float shadowScalar		= ComputeShadow( In.ShadowCoord, ShadowMap );
#else
	float shadowScalar		= 1.0f;
#endif

	// Compute our light blending term by interpolating between shadow and RNM values.  If we are in a sun occluded
	// area of the RNM we always want to take the RNM value (since this includes bounce light in the shadowed areas),
	// otherwise if we are not occluded by the sun we interpolate towards the shadow fill color for the area based on
	// the amount of dynamic shadowing that this pixel is in.
	float3 lightBlend		= lerp( rnmColor, ShadowColor, min( (1.0f - shadowScalar) * ShadowColor.a, sunOcclusion ) );
#if GLOW
	// Interpolate the light blending term towards maximum based on the glow mask for self illumination
	lightBlend				= lerp( lightBlend, float3( 1.0f, 1.0f, 1.0f ), maskColor.g );
#endif
    OutColor.rgb            += lightBlend * diffuseColor;

    // $$ Temporarily add sun spec.  We do not want specular highlights if we are either occluded by the sun or occluded
    //    by a dynamic shadow, so for now we just multiply both of these terms into our specular.
    OutColor.rgb			+= SpecularFormula( SunColor * maskColor.b, SunDirection, reflView, RampMap, SpecularRampOffset ) * shadowScalar * sunOcclusion;
#else
	// Sun lighting, use if RNM maps are not available
	float3 sunContrib		= ComputeLight( SunDirection, normal, reflView,
											SunColor, diffuseColor.rgb, maskColor.b,
											RampMap, DiffuseRampOffset, SpecularRampOffset );
											
#if DYNAMIC_SHADOWS
	// Multiply in the shadow amount
	OutColor.rgb			+= sunContrib * ComputeShadow( In.ShadowCoord, ShadowMap );
#else
	OutColor.rgb			+= sunContrib;
#endif
#endif

	// Return the finished color, blending in the fog
#if FOG
	return ComputeOutColor( OutColor, viewVec.xyz, FogColor.rgb );
#else
	return OutColor;
#endif
#endif
#endif
}
