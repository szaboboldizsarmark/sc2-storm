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


//////////////////////////////////////////////////////////////////////////////
// Vertex input/output definitions

#if STATIC

struct VS_INPUT
{
	float3 Position			: POSITION0;	// Contains static vertex position
	float3 TexCoord			: TEXCOORD0;	// Contains static vertex projected texture coordinates
	float4 ScaleOffset		: TEXCOORD1;	// Contains static vertex texture coordinate scale and offset into the decal atlas
	float3 TangentXform0	: TANGENT;		// Contains static vertex transform to proper tangent space, column 0
	float3 TangentXform1	: BINORMAL;		// Contains static vertex transform to proper tangent space, column 1
	float3 TangentXform2	: NORMAL;		// Contains static vertex transform to proper tangent space, column 2
};

#elif DYNAMIC

struct VS_INPUT
{
	float4 Position			: POSITION0;	// Contains static vertex position
	float4 TexCoord			: TEXCOORD0;	// Contains static vertex projected texture coordinates, alpha in w
#if NORMAL_MAP
	float4 TangentXform0	: TEXCOORD1;	// Contains static vertex transform to proper tangent space, column 0
	float4 TangentXform1	: TEXCOORD2;	// Contains static vertex transform to proper tangent space, column 1
#endif
};

#endif

struct VS_OUTPUT
{
	float4 Position			: POSITION;		// Contains vertex shader output position, not used in pixel shader
#if STATIC
	float3 TexCoord			: TEXCOORD0;	// Contains projected texture coordinates
#elif DYNAMIC
	float4 TexCoord			: TEXCOORD0;	// Contains projected texture coordinates
#endif
#if NORMAL_MAP
	float3 TangentXform0	: TEXCOORD1;	// Contains transform to proper tangent space, column 0
	float3 TangentXform1	: TEXCOORD2;	// Contains transform to proper tangent space, column 1
	float3 TangentXform2	: TEXCOORD3;	// Contains transform to proper tangent space, column 2
#endif
#if STATIC
	float2 ScaleOffset		: TEXCOORD4;	// Contains scale and offset into the decal atlas
#endif	
};


//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VS_OUTPUT DecalVS( VS_INPUT In )
{
	// Output from vertex shader
	VS_OUTPUT Out			= (VS_OUTPUT)0;

	// Build output position
	Out.Position			= mul( float4( In.Position.xyz, 1 ), ViewProj );
	
	// Build texture coordinates
#if STATIC
	Out.TexCoord			= In.TexCoord;
#elif DYNAMIC
	Out.TexCoord.xyz		= In.TexCoord.xyz;
	Out.TexCoord.w			= saturate( (In.Position.w - Time) * 0.25f );
#endif
	
#if NORMAL_MAP
#if STATIC	
	// Copy the tangent transform
	Out.TangentXform0		= In.TangentXform0;
	Out.TangentXform1		= In.TangentXform1;
	Out.TangentXform2		= In.TangentXform2;
#elif DYNAMIC
	// Swizzle the tangent transform
	Out.TangentXform0		= float3( In.TexCoord.w, In.TangentXform0.xy );
	Out.TangentXform1		= float3( In.TangentXform0.zw, In.TangentXform1.x );
	Out.TangentXform2		= In.TangentXform1.yzw;
#endif
#endif

#if STATIC
	// Build the scaled and offset UV coordinates for texture lookup after clipping
	Out.ScaleOffset			= (In.TexCoord.xy * In.ScaleOffset.xy) + In.ScaleOffset.zw;
#endif
	
	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

struct PS_OUTPUT
{
#if MRT
    float4 Color[2] : COLOR0;
#else
	float4 Color	: COLOR0;
#endif
};

PS_OUTPUT DecalPS( VS_OUTPUT In )
{
	// Clip any pixels outside of the projected range of [0.0, 1.0]
	clip( floor( In.TexCoord.xyz ) * -sign( In.TexCoord.xyz ) );
	
	PS_OUTPUT Out			= (PS_OUTPUT)0;	

#if STATIC
	In.TexCoord.xy			= In.ScaleOffset.xy;
#endif

#if DIFFUSE_ONLY || MRT
	// Sample our texture maps using our texture coordinates
#if DIFFUSE_MAP
	float4 diffuseColor		= tex2D( DiffuseMap, In.TexCoord.xy );
#if DYNAMIC
	diffuseColor.a			*= In.TexCoord.w;
#endif
#else
	float4 diffuseColor		= float4( 1.0f, 1.0f, 1.0f, 0.0f );
#endif

	float4 outDiffuse		= float4( diffuseColor.rgb * diffuseColor.a, diffuseColor.a );
#if !MRT
	Out.Color				= outDiffuse;
#endif
#endif

#if NORMAL_ONLY || MRT
#if NORMAL_MAP
	float4 normalColor		= tex2D( NormalMap, In.TexCoord.xy );
#if DYNAMIC
	normalColor.a			*= In.TexCoord.w;
#endif
	
	float3 normal = normalColor.rgb * 2.0f - 1.0f;
	normal = normalize( mul( normal, float3x3( In.TangentXform0.xyz, In.TangentXform1.xyz, In.TangentXform2.xyz ) ) );
#if DXDY_NORMAL_MAPS
	normal.x = -normal.x / normal.z;
	normal.y = -normal.y / normal.z;
	normal.z = 0.0f;
#endif

	// Scale the decal normal, transform it into the appropriate terrain tangent space, then scale it back and return the result
	float4 outNormal		= float4( (normal * 0.5f + 0.5f) * normalColor.a, normalColor.a );	
#else
	float4 outNormal		= float4( 0.0f, 0.0f, 0.0f, 0.0f );
#endif

#if !MRT
	Out.Color				= outNormal;
#endif
#endif

	// If we are using multiple render targets, then build our output structure
#if MRT
	Out.Color[0]			= outDiffuse;
	Out.Color[1]			= outNormal;
#endif

	return( Out );
}
