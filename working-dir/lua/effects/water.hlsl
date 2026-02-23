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
sampler2D	Diffuse2Map;
sampler2D   Normal1Map;
sampler2D   Normal2Map;
sampler2D   Normal3Map;
sampler2D   Normal4Map;
sampler2D   Mask1Map;
sampler2D	RampMap;

// Samplers that come from source map art
samplerCUBE EnvironmentMap;
sampler2D	LightRampMap;

// Samplers for shadows, refraction, reflection, and full scene depth
sampler2D	ShadowMap;
sampler2D	DepthMap;
sampler2D	RefractionMap;
sampler2D	ReflectionMap;

// Sampler for the fog of war
sampler2D	FogIntelMap;



//////////////////////////////////////////////////////////////////////////////
// Vertex input/output definitions

struct VS_INPUT
{
	float3 Position			: POSITION0;	// Contains static vertex position
	float2 TexCoordLocal	: TEXCOORD0;	// Contains static vertex texture coordinate set 1 (diffuse, normal, etc)
	float3 Normal			: NORMAL;		// Contains static vertex normal
	float3 Tangent			: TANGENT;		// Contains static vertex tangent
	float3 BiNormal			: BINORMAL;		// Contains static vertex binormal
};

#if Z_PASS

struct VS_OUTPUT
{
	float4 Position			: POSITION;		// Contains vertex shader output position, not used in pixel shader
#if DEPTH_OUT
	float Depth				: TEXCOORD0;	// Contains the linear normalized depth
#endif
#if FOGOFWAR_OUT
	float3 WorldPos			: TEXCOORD1;	// Contains the world space position
#endif
};

#else

struct VS_OUTPUT
{
	float4 Position			: POSITION;		// Contains vertex shader output position, not used in pixel shader	

	float2 TexCoord			: TEXCOORD0;	// Contains local texture coordinates

	float4 ScreenCoord		: TEXCOORD1;	// Contains the screen coordinate
	float4 ShadowCoord		: TEXCOORD2;	// Contains the shadow coordinate
	
	float3 Normal			: TEXCOORD3;	// Contains the vertex normal in xyz
	float3 Tangent			: TEXCOORD4;	// Contains the vertex tangent in xyz
	float3 BiNormal			: TEXCOORD5;	// Contains the vertex binormal in xyz
	
	float4 ViewVec			: TEXCOORD6;	// Contains world space view vector in xyz, linear normalized scene depth in w
#if DYNAMIC_LIGHT
	float3 LightVec			: TEXCOORD7;	// The light vector in world space with the light intensity
#endif
};

#endif


//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VS_OUTPUT WaterVS( VS_INPUT In )
{
	// Output from vertex shader
	VS_OUTPUT Out			= (VS_OUTPUT)0;

	// Build output position
	Out.Position			= mul( float4( In.Position.xyz, 1 ), ViewProj );
	
	// During any z pass, we need to keep normalized linear depth	
#if Z_PASS
#if DEPTH_OUT
	Out.Depth				= dot( float4( In.Position.xyz, 1 ), OrthoDepth );
#endif

#if FOGOFWAR_OUT
	Out.WorldPos			= In.Position.xyz;
#endif

	return Out;
#else	

	// Build texture coordinates
	Out.TexCoord			= In.TexCoordLocal;

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
	Out.ViewVec.xyz			= ViewPosition - In.Position.xyz;
	
	// Linear normalized depth
	Out.ViewVec.w			= dot( float4( In.Position.xyz, 1 ), OrthoDepth );

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

float4 WaterPS( VS_OUTPUT In ) : COLOR
{
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

	// Calculate dynamic light attenuation and clip pixel if it cannot contribute
#if DYNAMIC_LIGHT
	float atten				= 1 - dot( In.LightVec.xyz, In.LightVec.xyz );
	clip( atten );
#endif

#if DIFFUSE1_MAP
	float4 diffuse1Color	= tex2D( Diffuse1Map, (In.TexCoord.xy * WaterDiffuse1Movement.z) + (WaterDiffuse1Movement.xy * Time)  );
#else
	float4 diffuse1Color	= float4( 0.0f, 0.0f, 0.0f, 0.0f );
#endif

#if DIFFUSE2_MAP
	float4 diffuse2Color	= tex2D( Diffuse2Map, (In.TexCoord.xy * WaterDiffuse2Movement.z) + (WaterDiffuse2Movement.xy * Time)  );
#else
	float4 diffuse2Color	= float4( 0.0f, 0.0f, 0.0f, 0.0f );
#endif
	float3 foamColor		= diffuse1Color.rgb + diffuse2Color.rgb;

	// Sample our texture maps using our texture coordinates
#if NORMAL1_MAP
	float4 normal1Color		= tex2D( Normal1Map, (In.TexCoord.xy * WaterNormal1Movement.z) + (WaterNormal1Movement.xy * Time)  );
#else
	float4 normal1Color		= float4( 0.5f, 0.5f, 1.0f, 1.0f );
#endif

#if NORMAL2_MAP
	float4 normal2Color		= tex2D( Normal2Map, (In.TexCoord.xy * WaterNormal2Movement.z) + (WaterNormal2Movement.xy * Time)  );
#else
	float4 normal2Color		= float4( 0.5f, 0.5f, 1.0f, 1.0f );
#endif

#if NORMAL3_MAP
	float4 normal3Color		= tex2D( Normal3Map, (In.TexCoord.xy * WaterNormal3Movement.z) + (WaterNormal3Movement.xy * Time)  );
#else
	float4 normal3Color		= float4( 0.5f, 0.5f, 1.0f, 1.0f );
#endif

#if NORMAL4_MAP
	float4 normal4Color		= tex2D( Normal4Map, (In.TexCoord.xy * WaterNormal4Movement.z) + (WaterNormal4Movement.xy * Time)  );
#else
	float4 normal4Color		= float4( 0.5f, 0.5f, 1.0f, 1.0f );
#endif

	float4 depthColor		= float4( 0.0f, 0.0f, 0.0f, 1.0f );
	float2 depthSample		= saturate( ((ViewPosition.xz - In.ViewVec.xz) - WaterDepth.xy) * WaterDepth.zw );
#if MASK1_MAP
	depthColor				= tex2D( Mask1Map, depthSample );
#endif

	// Sample the wave animation texture to determine our wave foam
	float depthScalar		= saturate( (-depthColor.a + WaterWaves.x) * WaterWaves.y );
#if RAMP_MAP
	float4 waveAnim			= tex2D( RampMap, float2( depthScalar, frac( (Time * WaterWaves.z) + ((depthSample.x + depthSample.y) * WaterWaves.w) ) ) );
#else
	float4 waveAnim			= float4( 0.0f, 0.0f, 0.0f, 0.0f );
#endif

	// Calculate the averaged normal
	float3 normalSum		= normal1Color.rgb + normal2Color.rgb + normal3Color.rgb + normal4Color.rgb;
	float3 normal			= normalize( lerp( ((normalSum * 2.0f) - 4.0f), float3( (depthColor.rg * 2.0f - 1.0f) * (waveAnim.gg * 4.0f - 2.0f), waveAnim.g ), min( 1.0f, depthScalar * 2.0f ) ) );
	
	// Sample the screen color/depth in case we are unable to refract due to masking
	float invW				= 1.0f / In.ScreenCoord.w;
	float2 screenCoord		= In.ScreenCoord.xy * invW;
	float2 screenOffset		= normal.xy * invW;
	float4 screenColor		= tex2D( RefractionMap, screenCoord );
	float screenDepth		= tex2D( DepthMap, screenCoord ).r;
	
	// For each color channel (red, green, blue), perform refraction
	float4 refractColor		= float4( 0.0f, 0.0f, 0.0f, screenColor.a );
	float refractScale		= WaterScales.x * depthColor.a;
	
#if CHROMATIC_DISPERSION && WATER_QUALITY > 2
	// For each color channel (red, green, blue), perform refraction
	for( int i = 0; i < 3; ++i )
	{
		float2 refractCoord	= screenCoord + (screenOffset * refractScale);
		refractScale		+= WaterScales.w * depthColor.a;
		
		refractColor[i]		= tex2D( RefractionMap, refractCoord )[i];
		float refractDepth	= tex2D( DepthMap, refractCoord );
		
		float refractBlend	= step( refractDepth, In.ViewVec.w );
		refractDepth		= lerp( refractDepth, screenDepth, refractBlend );
		refractColor[i]		= lerp( lerp( refractColor[i], screenColor[i], refractBlend ), WaterColor[i], saturate( (refractDepth - In.ViewVec.w) * WaterScales.z ) );
	}
#else
	// Perform a single refraction pass
	float2 refractCoord		= screenCoord + (screenOffset * refractScale);
	
	refractColor.rgb		= tex2D( RefractionMap, refractCoord ).rgb;
	float refractDepth		= tex2D( DepthMap, refractCoord );
	
	float refractBlend		= step( refractDepth, In.ViewVec.w );
	refractDepth			= lerp( refractDepth, screenDepth, refractBlend );
	refractColor.rgb		= lerp( lerp( refractColor.rgb, screenColor.rgb, refractBlend ), WaterColor.rgb, saturate( (refractDepth - In.ViewVec.w) * WaterScales.z ) );
#endif
	
	// Take our normal and put it into world space
	normal					= normalize( mul( normal, float3x3( In.Tangent.xyz, In.BiNormal.xyz, In.Normal.xyz ) ) );
	
	// Calculate the fresnel term
	float3 normViewVec		= normalize( In.ViewVec.xyz );
	float viewIncidence		= max( dot( normViewVec, normal ), 0.0f );
	float facingIncidence	= 1.0f - viewIncidence;
	float fresnelTerm		= max( WaterLighting.x + (1.0 - WaterLighting.x) * pow( facingIncidence, WaterLighting.y ), 0.0f );
	
	// Blend between our refraction color and the water color based on incidence
	float4 waterColor		= lerp( refractColor, WaterColor, facingIncidence );
	
	// Add whitecap foam
	waterColor.rgb			+= foamColor * (saturate( normalSum.z - WaterWhiteCap.x ) * WaterWhiteCap.y) * (1.0f - depthScalar);
	
	// Calculate foam for waves
	float3 shoreColor		= foamColor * waveAnim.a;
	
	// Add a small amount of foam just for being in shallow water
	shoreColor				+= foamColor * saturate( -depthColor.a + WaterWhiteCap.z );
	
	// Reflection and sun
	float3 reflView			= -reflect( normViewVec, normal );
	float sunStrength		= pow( Lambert( SunDirection, reflView ), WaterLighting.z );
#if DYNAMIC_SHADOWS && WATER_QUALITY > 2
	sunStrength				*= ComputeShadow( In.ShadowCoord, ShadowMap );
#endif

	float3 reflectColor		= SunColor * sunStrength;
#if REFLECT && WATER_QUALITY > 1
	reflectColor			+= tex2D( ReflectionMap, screenCoord + (screenOffset * WaterScales.y) ).rgb;
#elif ENVIRONMENT_MAPPING || WATER_QUALITY == 1
	reflectColor			+= texCUBE( EnvironmentMap, reflView ).rgb;
#endif
	reflectColor			*= fresnelTerm;
	
	// Calculate final color
	float4 finalColor		= float4( waterColor.rgb + reflectColor + shoreColor, waterColor.a + (sunStrength * WaterLighting.w) );
	finalColor				= lerp( finalColor, screenColor, min( 1.0f, depthScalar * 1.5f ) );
	
	// Add intel overlay into the diffuse color
	float3 worldPos			= ViewPosition.xyz - In.ViewVec.xyz;
	float4 intelColor		= tex2D( FogIntelMap, worldPos.xz * FogIntel.xy );
	if( intelColor.a > 0.5f )
	{
		intelColor			*= 1.0f - saturate( (abs( worldPos.y - IntelHeightValues.x ) - IntelHeightValues.y) * IntelHeightValues.z );
		finalColor.rgb		= (finalColor.rgb * (1.0f - (intelColor.a * FogIntel.w))) + (intelColor.rgb * FogIntel.w);
	}
	
	// Blend with fog
	return ComputeOutColor( finalColor, In.ViewVec.xyz, FogColor.rgb );
#endif
}