//////////////////////////////////////////////////////////////////////////////
//
// Global constants are defined in global_constants.hlsl
//
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Textures/Samplers used by this shader

// Samplers that come from source map art
samplerCUBE SkyMap;


//////////////////////////////////////////////////////////////////////////////
// Vertex input/output definitions

struct VS_INPUT
{
	float3 Position			: POSITION0;	// Contains static vertex position
};

struct VS_OUTPUT
{
	float4 Position			: POSITION;		// Contains vertex shader output position, not used in pixel shader
	
	float3 ViewVec			: TEXCOORD0;	// Contains world space view vector in xyz
};


//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VS_OUTPUT SkyVS( VS_INPUT In )
{
	// Output from vertex shader
	VS_OUTPUT Out			= (VS_OUTPUT)0;

	// Build output position
	Out.Position			= mul( float4( In.Position.xyz, 1 ), ViewProj );
	Out.Position.z			= Out.Position.w;
	
	// Calculate view vector
	Out.ViewVec				= In.Position.xyz - ViewPosition;

	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 SkyPS( VS_OUTPUT In ) : COLOR
{
	// Sample our texture maps using our texture coordinates
	float4 OutColor			= texCUBE( SkyMap, In.ViewVec );
	
	// Return the finished color
	return OutColor;
}