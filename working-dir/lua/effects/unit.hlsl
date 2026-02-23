//////////////////////////////////////////////////////////////////////////////
//
// Global constants are defined in global_constants.hlsl
//
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Textures/Samplers used by this shader

// Samplers that come from source material art
sampler2D   DiffuseMap;
sampler2D   NormalMap;
sampler2D	MaskMap;
sampler2D   UtilityMap;
sampler2D	RampMap;
sampler2D	DamageMap;
sampler2D	DetailMap;
sampler2D	EffectMap;

// Samplers that come from source map art
samplerCUBE EnvironmentMap;
sampler2D	LightRampMap;
sampler3D	PcloudUpMap;
sampler3D	PcloudDownMap;

// Sampler for the shadow map
sampler2D	ShadowMap;

// Sampler for the fog of war map
sampler2D	FogIntelMap;


//////////////////////////////////////////////////////////////////////////////
// Ramp texel offsets
#define		RampMapHeight				8.0f
#define		DiffuseRampOffset			0.5f / RampMapHeight
#define		SpecularRampOffset			1.5f / RampMapHeight
#define		EnvironmentRampOffset		2.5f / RampMapHeight
#define		EffectRampOffset			3.5f / RampMapHeight

//////////////////////////////////////////////////////////////////////////////
// Global constants for specific shader macros
#if PULSE_ALPHA

#if SHIELD_DOME
#define		ShieldDomeMinAlpha			0.35f
#endif

#endif



//////////////////////////////////////////////////////////////////////////////
// Vertex input/output definitions

struct VS_INPUT
{
	// Stream 0 static vertex data
#if SKINNING > 1	
	float3 Position		: POSITION0;	// Contains static vertex position
	int4 BoneIndices	: BLENDINDICES;	// Contains static vertex bone indices
	float4 BoneWeights	: BLENDWEIGHT;	// Contains static vertex bone weights
#else
	float4 Position		: POSITION0;	// Contains static vertex position, single bone index in w
#endif
	float2 TexCoord		: TEXCOORD0;	// Contains static vertex texture coordinates
	
#if !Z_PASS || LEAF_SWAY
	float3 Normal		: NORMAL;		// Contains static vertex normal
#if !Z_PASS
	float3 Tangent		: TANGENT;		// Contains static vertex tangent
	float3 BiNormal		: BINORMAL;		// Contains static vertex binormal
#endif
#endif
	
	// Stream 1 instance data
	int4 Indices		: TEXCOORD1;	// Contains the index to the instance transform in 0, light dir/ramp indices in 1 and 2
#if !Z_PASS
#if SHIELD_PANEL || FADE_TIME
	float2 EffectVar	: TEXCOORD2;	// Contains the instance specific effect control variables
#endif
	
#if NUM_LIGHTS > 0
	float4 LightPos1	: TEXCOORD3;	// Contains the world space light position in xyz and reciprocal of light distance in w
#if NUM_LIGHTS > 1	
	float4 LightPos2	: TEXCOORD4;	// Contains the world space light position in xyz and reciprocal of light distance in w
#endif
#endif
#endif
	
#if ANIM_UVR
	float4 AnimUVR		: TEXCOORD5;	// Contains the u shift, v shift, sin(theta) rotation, and cos(theta) rotation
#endif
};

#if Z_PASS

struct VS_OUTPUT
{
	float4 Position		: POSITION;		// Contains vertex shader output position, not used in pixel shader
#if defined( ALPHA_TEST ) || DEPTH_OUT || SHADOW_COLOR_OUTPUT
	float3 TexCoord		: TEXCOORD0;	// Contains texture coordinates in xy, linear z in z
	float3 WorldPos		: TEXCOORD1;	// Contains the world space position of this vertex
#endif
};

#else

struct VS_OUTPUT
{
	float4 Position		: POSITION;		// Contains vertex shader output position, not used in pixel shader
	float3 TexCoord		: TEXCOORD0;	// Contains texture coordinates in xy, linear z in z

	float4 Normal		: TEXCOORD1;	// Contains the vertex normal in xyz, world space vertex x in w
	float4 Tangent		: TEXCOORD2;	// Contains the vertex tangent in xyz, world space vertex y in w
	float4 BiNormal		: TEXCOORD3;	// Contains the vertex binormal in xyz, world space vertex z in w
	
#if SHIELD_PANEL || FADE_TIME	
	float2 EffectVar	: TEXCOORD4;	// Contains the instance specific effect control variables
#endif		
	
#if NUM_LIGHTS > 0
	float4 LightVec1	: TEXCOORD5;	// Contains the light vector in world space in xyz, light index in w
#if NUM_LIGHTS > 1
	float4 LightVec2	: TEXCOORD6;	// Contains the light vector in world space in xyz, light index in w
#endif
#endif

	float4 ShadowCoord	: TEXCOORD7;	// Contains the shadow mapping coordinates
};

#endif

#ifdef XBOX

//////////////////////////////////////////////////////////////////////////////
// Vertex fetching for Xbox 360 instancing

float4 FetchPosition( int index )
{
    float4 pos;
    asm {
        vfetch pos, index, position0;
    };
    return pos;
}

int4 FetchBoneIndices( int index )
{
    int4 bone;
    asm {
        vfetch bone, index, blendindices0;
    };
    return bone;
}

float4 FetchBoneWeights( int index )
{
    float4 weights;
    asm {
        vfetch weights, index, blendweight0;
    };
    return weights;
}

float3 FetchNormal( int index )
{
    float4 norm;
    asm {
        vfetch norm, index, normal0;
    };
    return norm.xyz;
}

float3 FetchTangent( int index )
{
    float4 tang;
    asm {
        vfetch tang, index, tangent0;
    };
    return tang.xyz;
}

float3 FetchBiNormal( int index )
{
    float4 bi;
    asm {
        vfetch bi, index, binormal0;
    };
    return bi.xyz;
}

float2 FetchTexcoord( int index )
{
    float4 tex;
    asm {
        vfetch tex, index, texcoord0;
    };
    return tex.xy;
}

int4 FetchIndices( int index )
{
    int4 indices;
    asm {
        vfetch indices, index, texcoord1;
    };
    return indices;
}

float4 FetchLightPos1( int index )
{
    float4 pos;
    asm {
        vfetch pos, index, texcoord3;
    };
    return pos;
}

float4 FetchLightPos2( int index )
{
    float4 pos;
    asm {
        vfetch pos, index, texcoord4;
    };
    return pos;
}

float2 FetchEffectVar( int index )
{
    float4 effect;
    asm {
        vfetch effect, index, texcoord2;
    };
    return effect;
}

float4 FetchAnimUVR( int index )
{
    float4 uvr;
    asm {
        vfetch uvr, index, texcoord5;
    };
    return uvr;
}

VS_INPUT CreateVertexInput( int index )
{
    // Compute the instance index
    int nNumVertsPerInstance = VertsPerInstance;
    int nInstIndex = ( index + 0.5 ) / nNumVertsPerInstance;
    int nMeshIndex = index - nInstIndex * nNumVertsPerInstance;

    // Fetch the mesh vertex data
	VS_INPUT vertexInput	= (VS_INPUT)0;
    
    // Per vertex data
#if SKINNING > 1 
    vertexInput.Position	= FetchPosition( nMeshIndex ).xyz;
    vertexInput.BoneIndices = FetchBoneIndices( nMeshIndex );
    vertexInput.BoneWeights = FetchBoneWeights( nMeshIndex );
#else
	vertexInput.Position	= FetchPosition( nMeshIndex );
#endif
	vertexInput.TexCoord	= FetchTexcoord( nMeshIndex );
	
#if !Z_PASS || LEAF_SWAY
    vertexInput.Normal		= FetchNormal( nMeshIndex );
#if !Z_PASS
    vertexInput.Tangent		= FetchTangent( nMeshIndex );
    vertexInput.BiNormal	= FetchBiNormal( nMeshIndex );
#endif
#endif
    
    // Per instance data
    vertexInput.Indices		= FetchIndices( nInstIndex );
#if !Z_PASS
#if SHIELD_PANEL || FADE_TIME
    vertexInput.EffectVar	= FetchEffectVar( nInstIndex );
#endif
#if NUM_LIGHTS > 0
    vertexInput.LightPos1	= FetchLightPos1( nInstIndex );
#endif
#if NUM_LIGHTS > 1
    vertexInput.LightPos2	= FetchLightPos2( nInstIndex );
#endif
#endif
#if ANIM_UVR
	vertexInput.AnimUVR		= FetchAnimUVR( nInstIndex );
#endif
    
    return vertexInput;
}

#endif


//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VS_OUTPUT UnitVS(
#ifndef XBOX
    VS_INPUT In
#else
    int index : INDEX
#endif
)
{
#ifdef XBOX
    VS_INPUT In			= CreateVertexInput( index );
#endif 

	// Output from vertex shader
	VS_OUTPUT Out		= (VS_OUTPUT)0;
	
#if SKINNING > 1
	float4 VertexWS		= float4( 0, 0, 0, 1 );
	float3 NormalWS		= float3( 0, 0, 0 );
	float3 TangentWS	= float3( 0, 0, 0 );
	float3 BiNormWS		= float3( 0, 0, 0 );
	
	for( int i = 0; i < SKINNING; ++i )
	{
		float4x3 bMat	= Matrices[ In.BoneIndices[i] + In.Indices[0] ];

		VertexWS.xyz	+= In.BoneWeights[i] * mul( float4( In.Position, 1.0f ), bMat );
#if Z_PASS
	}
#else
		NormalWS		+= In.BoneWeights[i] * mul( In.Normal,	 (float3x3)bMat );
		TangentWS		+= In.BoneWeights[i] * mul( In.Tangent,  (float3x3)bMat );
		BiNormWS		+= In.BoneWeights[i] * mul( In.BiNormal, (float3x3)bMat );	
	}
	
	NormalWS			= normalize( NormalWS );
	TangentWS			= normalize( TangentWS );
	BiNormWS			= normalize( BiNormWS );
#endif
#else
#if SKINNING
	float4x3 instTran	= Matrices[ (int)In.Position.w + In.Indices[0] ];
#else
	float4x3 instTran	= Matrices[ In.Indices[0] ];
#endif
	float3 vertexPos	= In.Position.xyz;
	
#ifdef WIND_SWAY
	// Put the wind direction into local space for this calculation
	float2 localWindDir	= mul( float3( WindDirection.x, 0.0f, WindDirection.y ), transpose( (float3x3)instTran ) ).xz;
	
	// Calculate a unique phase for each tree so they all appear to move individually
	float treePhase		= dot( instTran[3], float3( 1.0f, 1.0f, 1.0f ) );

	// Calculate the bend factor from the height off the ground
	float bendFactor	= (WIND_SWAY * 0.01f) * vertexPos.y * WindDirection.z;
	
	// Calculate the wave approximation
	float2 treeWaves	= (frac( (treePhase + Time) * float2( 0.075, 0.0413f ) ) * 2.0f - 1.0f);
	treeWaves			= SmoothTriangleWave( float4( treeWaves, 0.0f, 0.0f ) ).xy * bendFactor;
	
	// Build the displaced position
	float3 newPos		= vertexPos;
	newPos.xz			+= localWindDir * (treeWaves.x + treeWaves.y);
	vertexPos			= normalize( newPos.xyz ) * length( vertexPos );
#endif // WIND_SWAY

	float4 VertexWS		= float4(	 mul( float4( vertexPos, 1.0f ), instTran ), 1 );
#if !Z_PASS	|| LEAF_SWAY
	float3 NormalWS		= normalize( mul( In.Normal,	(float3x3)instTran ) );
#if !Z_PASS
	float3 TangentWS	= normalize( mul( In.Tangent,	(float3x3)instTran ) );
	float3 BiNormWS		= normalize( mul( In.BiNormal,	(float3x3)instTran ) );
#endif
#endif

#ifdef LEAF_SWAY
	// Calculate a unique phase for each leaf vertex so they all appear to move individually
	float leafPhase		= dot( VertexWS.xyz, float3( 1.0f, 1.0f, 1.0f ) );
	
	// Calculate the wave approximation
	float4 leafWaves	= float4( leafPhase + (Time * WindDirection.z * 0.5f), 0.0f, 0.0f, 0.0f );
	leafWaves			= (frac( leafWaves.xxxx * float4( 1.975f, 0.793f, 0.375f, 0.193f ) ) * 2.0f - 1.0f);
	leafWaves			= SmoothTriangleWave( leafWaves ) * (LEAF_SWAY * 0.01f);
	float2 leafWavesSum	= leafWaves.xz + leafWaves.yw;
	
	// Add the position in
	VertexWS.xyz		+= leafWavesSum.xyx * NormalWS.xyz;
#endif // LEAF_SWAY

#endif

#if !Z_PASS
	// Build shadow output coordinates
	// NOTE:  The ordering of this calculation appears to be important to the Xbox 360 shader compiler.  It must be done before
	//        the output position is calculated, otherwise there is a slight difference in the output w.
	Out.ShadowCoord		= mul( VertexWS, Shadow );
#if SHADOW_COLOR_OUTPUT
	Out.ShadowCoord.z	= min( 0.999f, dot( VertexWS, ShadowDepth ) );
#endif	
#endif
	
	// Build output position
	Out.Position		= mul( VertexWS, ViewProj );
	
#if Z_PASS && MAX_DEPTH
	Out.Position.z		= Out.Position.w;
#endif

#if Z_PASS && !SHADOW_COLOR_OUTPUT && !defined( ALPHA_TEST ) && !defined( DEPTH_OUT )
	return Out;
#else
	
	// Build texture coordinates
#if ANIM_UVR
	float3 uvr			= float3( In.TexCoord.xy, 1.0f );
	Out.TexCoord.x		= dot( uvr, In.AnimUVR.yxz );
	Out.TexCoord.y		= dot( uvr, float3( -In.AnimUVR.x, In.AnimUVR.yw ) );
#else
	Out.TexCoord.xy		= In.TexCoord.xy;
#endif

#if Z_PASS
	// Write out the orthographic depth
	Out.TexCoord.z		= dot( VertexWS, OrthoDepth );
	
	// Write out the world position
	Out.WorldPos.xyz	= VertexWS.xyz;
#else

	// Transfer tangent basis to pixel shader
	Out.Normal			= float4( NormalWS, VertexWS.x );
	Out.Tangent			= float4( TangentWS, VertexWS.y );
	Out.BiNormal		= float4( BiNormWS, VertexWS.z );
	
#if SHIELD_PANEL || FADE_TIME
	// Transfer the effect control variable to the pixel shader
	Out.EffectVar		= In.EffectVar;
#endif	
	
#if NUM_LIGHTS > 0
	// Build light information for light1
	Out.LightVec1		= float4( (In.LightPos1.xyz - VertexWS.xyz) * In.LightPos1.w, (float)(In.Indices[1] + 0.5f) );
#endif
#if NUM_LIGHTS > 1
	// Build light information for light2
	Out.LightVec2		= float4( (In.LightPos2.xyz - VertexWS.xyz) * In.LightPos2.w, (float)(In.Indices[2] + 0.5f) );
#endif
#endif
#endif

	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 UnitPS( VS_OUTPUT In ) : COLOR
{
#if Z_PASS
#if ALPHA_TEST
	float4 diffuseColor	= tex2D( DiffuseMap, In.TexCoord.xy );
	clip( (diffuseColor.a * 255.0f) - (ALPHA_TEST + 1) );
#endif
	float4 result		= float4( 0.0f, 0.0f, 0.0f, 0.0f );
#if DEPTH_OUT || SHADOW_COLOR_OUTPUT
	result.r			= In.TexCoord.z;
#if DEPTH_OUT
	result.g			= tex2D( FogIntelMap, In.WorldPos.xz * FogIntel.xy ).a *
						  (1.0f - saturate( (abs( In.WorldPos.y - FogOfWarHeightValues.x ) - FogOfWarHeightValues.y) * FogOfWarHeightValues.z ));
#endif
#endif
	return result;
#else

	// Get the interpolated texture coordinates
	float2 coords		= In.TexCoord.xy;
	
	// Sample our texture maps using our texture coordinates
#if DIFFUSE_MAP
	float4 diffuseColor	= tex2D( DiffuseMap, In.TexCoord.xy );
#ifdef ALPHA_TEST
	clip( (diffuseColor.a * 255.0f) - (ALPHA_TEST + 1) );
#endif
#else
	float4 diffuseColor	= float4( 1.0f, 1.0f, 1.0f, 1.0f );
#endif	

#if NORMAL_MAP
	float4 normalColor	= tex2D( NormalMap, coords.xy ).NORMAL_MAP_CHANNELS;
#else
	float4 normalColor	= DEFAULT_PACKED_NORMAL_DATA;
#endif

#if MASK_MAP
	float4 maskColor	= tex2D( MaskMap, coords.xy );
#else
	float4 maskColor	= float4( 0.0f, 0.0f, 1.0f, 0.0f );
#endif

#if UTILITY_MAP
	float4 utilityColor	= tex2D( UtilityMap, coords.xy );
	
	// Process team color
#if TEAM_COLOR
	diffuseColor.rgb	= lerp( lerp( diffuseColor.rgb, TeamColor1.rgb, utilityColor.a ), TeamColor2.rgb, utilityColor.g );
#endif

#else
	float4 utilityColor	= float4( 0.0f, 0.0f, 0.0f, 0.0f );
#endif

#if EFFECT_MAP
	float4 effectColor	= tex2D( EffectMap, coords.xy );
#else
	float4 effectColor	= float4( 0.0f, 0.0f, 0.0f, 0.0f );
#endif

#if WRECKAGE
	// Dirty up the diffuse texture by using the effects masks to subtract color from the diffuse texture
	// and add in a noise for burning edge highlighting

	diffuseColor.rgb	= diffuseColor.rgb - effectColor.a;
	
#if WRECKAGE_EDGE_HIGHLIGHT	
	float utilityMask	= tex2D( EffectMap, coords.xy + (Time * 0.005) ).g * effectColor.r;	
	diffuseColor.rgb += float3( 1.0f, 0.61f, 0.1f ) * utilityMask;
#endif
#endif

#if BUILD_OVERLAY
	float1 panelLevel = effectColor.b;
	float1 midpoint = (sin(Time * 0.5) + 0.9) * 0.45;

	// Faded range cycling
	//float1 pxValue = (panelLevel - abs(midpoint - 0.2f)) * 5.0f;
	//float1 panelOverlay = max(0, (floor(pxValue) * -sign(pxValue)) + 1.0f) * pxValue;
	
	// Hard range cycling
	float1 panelOverlay = ceil(step( midpoint - 0.15f, panelLevel ) * step( panelLevel, midpoint + 0.15f ) * panelLevel);	
	diffuseColor.rgb -= panelOverlay.rrr * effectColor.rrr * float3( 0.5, 0.6, 1.0 );
#endif 

	// Our output color
	float4 OutColor		= diffuseColor;

#if GLOW
	OutColor.a			= maskColor.g;
#elif !ALPHA_BLEND
	OutColor.a			= 0.0f;
#endif

#if WRECKAGE_EDGE_HIGHLIGHT
	// Add glow into the wreckage edge highlights
	OutColor.a			+= utilityMask;
#endif

#if AMBIENT_LIGHTING
	// Modulate our ambient/shadow color into the current result
	float3 ambientColor	= ShadowColor;
#if AMBIENT_OCCLUSION
	ambientColor		*= maskColor.a;
#endif

#if GLOW
	OutColor.rgb		*= lerp( ambientColor, float3( 1.0f, 1.0f, 1.0f ), maskColor.g );
#else
	OutColor.rgb		*= ambientColor;
#endif
#endif

	// Compute final normal
	float3 normal 		= ComputeNormalVectorFromPackedNormalData( normalColor.rgb );

	// Transform the normal from tangent space to world space
	// Note that the normalize here could be removed if the normal map textures were guaranteed normalized
	normal				= normalize( mul( normal, float3x3( In.Tangent.xyz, In.BiNormal.xyz, In.Normal.xyz ) ) );
	
	// Build the reflected view vector for this pixel
	float3 worldPos		= float3( In.Normal.w, In.Tangent.w, In.BiNormal.w );
	float3 viewVec		= ViewPosition - worldPos;
	float3 reflView		= -reflect( normalize( viewVec ), normal );
	
	float3 lightContrib = float3( 0.0f, 0.0f, 0.0f );
	
#if ENVIRONMENT_MAPPING

#if CHROME
	// Overbrighten the EnvironmentMap 
	float3 environment = ComputeEnvironment( normal, reflView, maskColor.r * 1.5, RampMap, EnvironmentMap, EnvironmentRampOffset );
#else
	// Compute the environment contribution
	float3 environment = ComputeEnvironment( normal, reflView, maskColor.r, RampMap, EnvironmentMap, EnvironmentRampOffset );
#endif
	lightContrib		+= environment;
								   
#endif

	// Add the sun lighting
	float3 sunLight		= ComputeLight( SunDirection, normal, reflView,
										SunColor, diffuseColor.rgb, maskColor.b,
										RampMap, DiffuseRampOffset, SpecularRampOffset );

#if POINT_CLOUD
	// Sample the point cloud textures
	float3 pcloudCoord	= (worldPos - PointCloudPos) * PointCloudScale;
	float3 pcloudUp		= tex3D( PcloudUpMap, pcloudCoord.xzy ).rgb;
	float4 pcloudDown	= tex3D( PcloudDownMap, pcloudCoord.xzy );
	
	lightContrib		+= DiffuseFormula( pcloudUp.rgb * PointCloudLightAmount, float3( 0.0f, 1.0f, 0.0f ), normal, RampMap, DiffuseRampOffset );
	lightContrib		+= DiffuseHalfLambertFormula( pcloudDown.rgb * PointCloudLightAmount, float3( 0.0f, -1.0f, 0.0f ), normal, RampMap, DiffuseRampOffset );
	
	// Multiply down the sun lighting by the point cloud occlusion
	sunLight			*= pcloudDown.a;
#endif

#if NO_SELF_SHADOW
	lightContrib		+= sunLight;
#else
	lightContrib		+= sunLight * ComputeShadow( In.ShadowCoord, ShadowMap );
#endif
										 
#if NUM_LIGHTS > 0
	// Add the first light
	lightContrib		+= ComputeSpotLight( normalize( In.LightVec1.xyz ), LightDirRamp[ (int)In.LightVec1.w ], normal, reflView,
											 diffuseColor.rgb, maskColor.b, 1 - saturate( dot( In.LightVec1.xyz, In.LightVec1.xyz ) ),
											 LightRampMap, RampMap,
											 DiffuseRampOffset, SpecularRampOffset );
#endif
#if NUM_LIGHTS > 1
	// Add the second light
	lightContrib		+= ComputeSpotLight( normalize( In.LightVec2.xyz ), LightDirRamp[ (int)In.LightVec2.w ], normal, reflView,
											 diffuseColor.rgb, maskColor.b, 1 - saturate( dot( In.LightVec2.xyz, In.LightVec2.xyz ) ),
											 LightRampMap, RampMap,
											 DiffuseRampOffset, SpecularRampOffset );
#endif
										 
	// Ambient occlusion
#if AMBIENT_OCCLUSION
	OutColor.rgb		+= lightContrib * maskColor.a;
#else
	OutColor.rgb		+= lightContrib;
#endif


#if EDGE_HIGHLIGHT
#if NORMAL_MAP
	float NdotV = pow(1 - saturate(dot( normalize(viewVec), normal )), 0.5);
#else
	float NdotV = pow(1 - saturate(dot( normalize(viewVec), In.Normal.xyz )), 0.5);
#endif

#if SHIELD_DOME
	OutColor.rgb *= NdotV +(0.3 * NdotV) * 1.5;
#else
	OutColor.rg *= NdotV;
	OutColor.b *= NdotV +(0.5 * NdotV);
#endif

	OutColor.a += pow(NdotV, 4.6) * 0.8;

#endif
	

#if SHIELD

#if NORMAL_MAP
	float NdotV = pow(1 - saturate(dot( normalize(viewVec), normal )), 2.9 );
#else
	float NdotV = pow(1 - saturate(dot( normalize(viewVec), In.Normal.xyz )), 2.9 );
#endif

	OutColor.rgb += NdotV;
	
	float2 shiftCoords = 4 * coords.xy + (Time * 0.05);
	float distortStr = 0.03;
	float2 chromeCoords = coords.xy * 2 + tex2D( EffectMap, shiftCoords ).gg * distortStr;
	float utilityMask = tex2D( EffectMap, chromeCoords - (Time * 0.05) ).a; 	
	
	OutColor.rgb += utilityMask * 0.7;
	OutColor.a += utilityMask * 0.4;
#endif	

#if CHROME
	// Add in effect noise over top of the 2nd team color mask using the effect texture.
	float2 shiftCoords = 2 * coords.xy + (Time * 0.02);
	float distortStr = 0.04;
	float2 chromeCoords = coords.xy * 4 + tex2D( EffectMap, shiftCoords ).gg * distortStr;
	float utilityMask = tex2D( EffectMap, chromeCoords - (Time * 0.01) ).a; 
	
#if BUILD_OVERLAY	
	OutColor.rgb += utilityMask * utilityColor.g;
	OutColor.rgb -= utilityMask * utilityColor.a;
#else
	OutColor.rgb += utilityMask * 0.5 * utilityColor.g;
#endif

#endif 

#if BUILD_OVERLAY	
	OutColor.a += (panelOverlay * 0.3);
#endif

#if SHIELD_DOME 
	float2 shiftCoords = coords.xy * 4;
	float distortStr = 0.6;
	float2 chromeCoords = coords.xy + tex2D( EffectMap, shiftCoords ).gg * distortStr;	
	float utilityMask = tex2D( EffectMap, chromeCoords - (Time * 0.1) ).a; 	
	OutColor.rgba -= utilityMask;
#endif

#if SHIELD_PANEL
	float NdotV2 = pow(1 - saturate(dot( normalize(viewVec), In.Normal.xyz )), 0.4);
	
	float2 shiftCoords = coords.xy * 3 + (Time * 0.02);
	float distortStr = 0.4;
	float2 chromeCoords = coords.xy + tex2D( EffectMap, shiftCoords ).gg * distortStr;	
	float utilityMask = tex2D( EffectMap, chromeCoords - (Time * 0.1) ).a; 	

	OutColor.rgba = utilityMask;
	OutColor.rgb += NdotV2 + (0.5 * NdotV2);
	OutColor.rgb *= diffuseColor.rgb;
	
	// On impact blow out our alpha to help sell the impact event
	OutColor.a += saturate( 0.1f - (Time - In.EffectVar.y) );	
#endif


// Fade mesh after fade time has been reached for fade duration if it exists
// Requires In.EffectVar.y, PARAM_LIFETIME to be set.
#if FADE_TIME
#if FADE_DURATION
	OutColor.a *= saturate( 1.0f - (Time - In.EffectVar.y - 0.3f) * 1.6f); 	
#else
	OutColor.a *= saturate( 1.0f - (Time - In.EffectVar.y - FADE_TIME)); 
#endif
#endif

#if PULSE_ALPHA

#if SHIELD_DOME 
	float minAlpha = ShieldDomeMinAlpha;
	OutColor.a *= ((sin( (Time * 3.14)/PULSE_ALPHA ) + 0.25) * 0.25) + minAlpha;
#else
	float minAlpha = 0.0f;
	OutColor.a *= ((sin( (Time * 3.14)/PULSE_ALPHA ) + 1) * 0.5) + minAlpha;
#endif

#endif

#if SHIELD_PANEL
	//OutColor = float4(1,1,1,1);
#endif
	
	// Return the finished color
	return ComputeOutColor( OutColor, viewVec, FogColor.rgb );
#endif
}
