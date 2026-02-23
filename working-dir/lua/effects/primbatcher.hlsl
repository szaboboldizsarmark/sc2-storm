//////////////////////////////////////////////////////////////////////////////
//
// Global constants are defined in global_constants.hlsl
//
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Textures/Samplers used by this shader

sampler2D BatcherMap;
sampler2D YMap;
sampler2D UMap;
sampler2D VMap;


//////////////////////////////////////////////////////////////////////////////
// Vertex input/output definitions

struct VS_INPUT
{
	float3 Position			: POSITION;
	float4 Color			: COLOR0;
	float2 TexCoord			: TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 Position			: POSITION;
#ifdef XBOX
	float4 Color			: COLOR0_center;
#else
    float4 Color			: COLOR0;
#endif
    float2 TexCoord			: TEXCOORD0;
};


//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VS_OUTPUT PrimBatcherVS( VS_INPUT In )
{
	// Output from vertex shader
	VS_OUTPUT Out			= (VS_OUTPUT)0;

	// Build output position
	Out.Position			= mul( float4( In.Position.xyz, 1 ), ViewProj );
	
	// Copy other components
#if RESOURCE
	Out.Color				= float4( 0.0f, 0.0f, 0.0f, length( float2( In.Position.x, In.Position.y ) ) * 0.00277f );
#else
	Out.Color				= In.Color;
#endif
	Out.TexCoord			= In.TexCoord;

	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 PrimBatcherPS( VS_OUTPUT In ) : COLOR
{
#if YELLOW
	return( float4( 1.0f, 1.0f, 0.0f, 1.0f ) );
#endif

#if RED
	return( float4( 1.0f, 0.0f, 0.0f, 1.0f ) );
#endif

#if MOVIE
	float4 TexY				= tex2D( YMap, In.TexCoord );
	float4 TexU				= tex2D( UMap, In.TexCoord ) - float4( 0.5f, 0.5f, 0.5f, 0.5f );
	float4 TexV				= tex2D( VMap, In.TexCoord ) - float4( 0.5f, 0.5f, 0.5f, 0.5f );
	float4 Color			= ( TexY.aaaa - float4( 0.0625f, 0.0625f, 0.0625f, 0.0625f ) ) * 1.164f;
	Color.a					= 1.0f;
	Color.r					+=  TexV.a * 1.596f;
	Color.g					+= -TexU.a * 0.392f -TexV.a * 0.813f;
	Color.b					+=  TexU.a * 2.017f;
	return Color;
#endif

	// Sample our texture maps using our texture coordinates
	float4 OutColor			= tex2D( BatcherMap, In.TexCoord );
	
#if GLOW
	OutColor.rgb			= float3( 0.0f, 0.0f, 0.0f );
#elif LIFEBAR
	OutColor.rgb			= In.Color.rgb;
#elif RESOURCE
	float sine				= sin( Time * 0.7f - 10.0f * In.Color.a );
	OutColor.a				*= sine * sine;
#elif STRATEGIC
	float3 d				= OutColor.rgb - float3( 0.5f, 0.5f, 0.5f );
	d						*= d;
	if( dot( d, float3( 1.0f, 1.0f, 1.0f ) ) < 0.25f )
	{
		OutColor.rgb		= In.Color.rgb;
	}
#elif SELECTION
	OutColor.rgb			= In.Color.rgb + float3(OutColor.g,OutColor.g,OutColor.g);
	OutColor.a				*= In.Color.a;
	OutColor				= clamp( OutColor, 0, 1 );
#elif MINIMAP_FOG
	OutColor.a				= 0.33f * (1.0f - OutColor.a);
	OutColor.rgb			= float3( 0.0f, 0.0f, 0.0f );				
#else
	OutColor				*= In.Color;
#endif
	
	// Return the finished color
	return OutColor;
}