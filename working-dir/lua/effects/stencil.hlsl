//////////////////////////////////////////////////////////////////////////////
//
// Global constants are defined in global_constants.hlsl
//
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Textures/Samplers used by this shader


//////////////////////////////////////////////////////////////////////////////
// Vertex input/output definitions

struct RangeVS_INPUT
{
	// Stream 0 static vertex data
	float2 Vertex			: POSITION0;
	float3 AlphaScalar		: TEXCOORD0;

	// Stream 1 instance data
	float2 Position			: POSITION1;
	float2 Radius			: TEXCOORD1;
};

struct RangeVS_OUTPUT
{
	float4 Position			: POSITION;
	float4 Color			: COLOR0;	
};

#ifdef XBOX

//////////////////////////////////////////////////////////////////////////////
// Vertex fetching for Xbox 360 instancing

float4 FetchRangeVertex( int index )
{
    float4 vert;
    asm {
        vfetch vert, index, position0;
    };
    return vert;
}

float4 FetchAlphaScalar( int index )
{
    float4 scalar;
    asm {
        vfetch scalar, index, texcoord0;
    };
    return scalar;
}

float4 FetchRangePosition( int index )
{
    float4 pos;
    asm {
        vfetch pos, index, position1;
    };
    return pos;
}

float4 FetchRangeRadius( int index )
{
    float4 radius;
    asm {
        vfetch radius, index, texcoord1;
    };
    return radius;
}

RangeVS_INPUT CreateRangeVertexInput( int index )
{
    // Compute the instance index
    int nNumVertsPerInstance = VertsPerInstance;
    int nInstIndex = ( index + 0.5 ) / nNumVertsPerInstance;
    int nMeshIndex = index - nInstIndex * nNumVertsPerInstance;

    // Fetch the mesh vertex data
	RangeVS_INPUT vertexInput = (RangeVS_INPUT)0;
	
    // Per vertex data
    vertexInput.Vertex		= FetchRangeVertex( nMeshIndex );
    vertexInput.AlphaScalar	= FetchAlphaScalar( nMeshIndex );
    
    // Per instance data
    vertexInput.Position	= FetchRangePosition( nInstIndex );
    vertexInput.Radius		= FetchRangeRadius( nInstIndex );
    
    return vertexInput;
}

#endif

//////////////////////////////////////////////////////////////////////////////
// Vertex shader

RangeVS_OUTPUT RangeVS(
#ifndef XBOX
    RangeVS_INPUT In
#else
    int index : INDEX
#endif
)
{
#ifdef XBOX
    RangeVS_INPUT In		= CreateRangeVertexInput( index );
#endif 

	// Output from vertex shader
	RangeVS_OUTPUT Out		= (RangeVS_OUTPUT)0;
	
	// Scale the vertex based on requested range, and add in the instanced position
#if FEATHER_OUT
	In.Vertex.xy			*= dot( In.AlphaScalar.yz, float2( In.Radius.y, In.Radius.y + FogIntel.z ) );
#endif
#if FEATHER_IN
	In.Vertex.xy			*= dot( In.AlphaScalar.yz, float2( max( 0.0f, In.Radius.y - FogIntel.z ), In.Radius.y ) );
#endif
	In.Vertex.xy			+= In.Position.xy - 1;
	
	// Scale the values by the map dimensions and then map to [-1,1]
	In.Vertex.xy			*= FogIntel.xy;
	In.Vertex.xy			= In.Vertex.xy * 2 - 1;
		
	// Transform vertex to homogenous clip space
	Out.Position			= float4( In.Vertex.x, -In.Vertex.y, 1.0f, 1.0f );
#if FEATHER_OUT
	Out.Color				= In.AlphaScalar.xxxx;
#endif
#if FEATHER_IN
	Out.Color				= float4( 1.0f, 1.0f, 1.0f, 1.0f ) - In.AlphaScalar.xxxx;
#endif
	
	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 RangePS( RangeVS_OUTPUT In ) : COLOR
{
	return( GlobalColor * In.Color );
}


//////////////////////////////////////////////////////////////////////////////
// Vertex input/output definitions

struct VisionVS_INPUT
{
	// Stream 0 static vertex data
	float2 Vertex			: POSITION0;
	float2 AlphaRad			: TEXCOORD0;

	// Stream 1 instance data
	float2 Position			: POSITION1;
	float  Radius			: TEXCOORD1;
};

struct VisionVS_OUTPUT
{
	float4 Position			: POSITION;
	float4 Color			: COLOR0;
};


#ifdef XBOX

//////////////////////////////////////////////////////////////////////////////
// Vertex fetching for Xbox 360 instancing

float2 FetchVisionVertex( int index )
{
    float4 vert;
    asm {
        vfetch vert, index, position0;
    };
    return vert.xy;
}

float2 FetchVisionAlphaRad( int index )
{
    float4 alpharad;
    asm {
        vfetch alpharad, index, texcoord0;
    };
    return alpharad.xy;
}

float4 FetchVisionPosition( int index )
{
    float4 pos;
    asm {
        vfetch pos, index, position1;
    };
    return pos;
}

float4 FetchVisionRadius( int index )
{
    float4 radius;
    asm {
        vfetch radius, index, texcoord1;
    };
    return radius;
}

VisionVS_INPUT CreateVisionVertexInput( int index )
{
    // Compute the instance index
    int nNumVertsPerInstance = VertsPerInstance;
    int nInstIndex = ( index + 0.5 ) / nNumVertsPerInstance;
    int nMeshIndex = index - nInstIndex * nNumVertsPerInstance;

    // Fetch the mesh vertex data
	VisionVS_INPUT vertexInput = (VisionVS_INPUT)0;
	
    // Per vertex data
    vertexInput.Vertex		= FetchVisionVertex( nMeshIndex );
    vertexInput.AlphaRad	= FetchVisionAlphaRad( nMeshIndex );
    
    // Per instance data
    vertexInput.Position	= FetchVisionPosition( nInstIndex );
    vertexInput.Radius		= FetchVisionRadius( nInstIndex );
    
    return vertexInput;
}

#endif


//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VisionVS_OUTPUT VisionVS(
#ifndef XBOX
    VisionVS_INPUT In
#else
    int index : INDEX
#endif
)
{
#ifdef XBOX
    VisionVS_INPUT In		= CreateVisionVertexInput( index );
#endif 

	// Output from vertex shader
	VisionVS_OUTPUT Out		= (VisionVS_OUTPUT)0;
	
	// Scale the vertex based on requested range, and add in the instanced position
	In.Vertex.xy			*= In.Radius + (In.AlphaRad.y * FogIntel.z);
	In.Vertex.xy			+= In.Position.xy - 1;
	
	// Scale the values by the map dimensions and then map to [-1,1]
	In.Vertex.xy			*= FogIntel.xy;
	In.Vertex.xy			= In.Vertex.xy * 2 - 1;
		
	// Transform vertex to homogenous clip space
	Out.Position			= float4( In.Vertex.x, -In.Vertex.y, 1.0f, 1.0f );
	Out.Color				= float4( 0.0f, 0.0f, 0.0f, In.AlphaRad.x );
	
	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 VisionPS( VisionVS_OUTPUT In ) : COLOR
{
	return( In.Color );
}