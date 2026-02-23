//////////////////////////////////////////////////////////////////////////////
//
// Global constants are defined in global_constants.hlsl
//
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Textures/Samplers used by this shader

// Samplers that come from source material art
sampler2D   Effect1Map;
sampler2D   Effect2Map;
sampler2D	Effect3Map;

// Screen texture for refraction effects
sampler2D	RefractionMap;



//////////////////////////////////////////////////////////////////////////////
// Vertex input/output definitions

struct ParticleVS_INPUT
{
	// Stream 0 static vertex data
	float2 Corner		: POSITION0;

	// Stream 1 instance data
	float4 Position		: POSITION1;
	float4 Size			: TEXCOORD0;
	float4 Velocity		: TEXCOORD1;
	float3 Acceleration	: TEXCOORD2;
	float4 Time			: TEXCOORD3;
	float3 TexOffset	: TEXCOORD4;
	float3 Drag			: TEXCOORD5;
	float4 Distortion	: TEXCOORD6;
};

struct ParticleVS_OUTPUT
{
	float4 Position		: POSITION;
	
	float2 TexCoord0	: TEXCOORD0;
#if EFFECT2_MAP
	float2 TexCoord1	: TEXCOORD1;
#endif
#if REFRACT
#if FLAT
	float4 ScreenCoord0	: TEXCOORD2;
	float4 ScreenCoord1	: TEXCOORD3;
#else
	float2 TexCoord2	: TEXCOORD2;
#endif
#endif
#if DISTORTION && EFFECT3_MAP
	float3 TexCoord3	: TEXCOORD4;
#endif
};

#ifdef XBOX

//////////////////////////////////////////////////////////////////////////////
// Vertex fetching for Xbox 360 instancing

float4 FetchCorner( int index )
{
    float4 corn;
    asm {
        vfetch corn, index, position0;
    };
    return corn;
}

float4 FetchPosition( int index )
{
    float4 pos;
    asm {
        vfetch pos, index, position1;
    };
    return pos;
}

float4 FetchSize( int index )
{
    float4 size;
    asm {
        vfetch size, index, texcoord0;
    };
    return size;
}

float4 FetchVelocity( int index )
{
    float4 velocity;
    asm {
        vfetch velocity, index, texcoord1;
    };
    return velocity;
}

float4 FetchAcceleration( int index )
{
    float4 accel;
    asm {
        vfetch accel, index, texcoord2;
    };
    return accel;
}

float4 FetchTime( int index )
{
    float4 time;
    asm {
        vfetch time, index, texcoord3;
    };
    return time;
}

float4 FetchTexOffset( int index )
{
    float4 offset;
    asm {
        vfetch offset, index, texcoord4;
    };
    return offset;
}

float4 FetchDrag( int index )
{
    float4 drag;
    asm {
        vfetch drag, index, texcoord5;
    };
    return drag;
}

float4 FetchDistortion( int index )
{
    float4 distortion;
    asm {
        vfetch distortion, index, texcoord6;
    };
    return distortion;
}

ParticleVS_INPUT CreateParticleVertexInput( int index )
{
	// Compute the instance index
	int nNumIndicesPerInstance = 4;
	int nInstIndex = ( index + 0.5 ) / nNumIndicesPerInstance;
	int nMeshIndex = index - nInstIndex * nNumIndicesPerInstance;

	// Fetch the mesh vertex data
	ParticleVS_INPUT vertexInput = (ParticleVS_INPUT)0;

	// Per vertex data
	vertexInput.Corner			= FetchCorner( nMeshIndex );

	// Per instance data
	vertexInput.Position		= FetchPosition( nInstIndex );
	vertexInput.Size			= FetchSize( nInstIndex );
	vertexInput.Velocity		= FetchVelocity( nInstIndex );
	vertexInput.Acceleration	= FetchAcceleration( nInstIndex );
	vertexInput.Time			= FetchTime( nInstIndex );
	
#if EFFECT2_MAP || ANIM
	vertexInput.TexOffset		= FetchTexOffset( nInstIndex );
#endif
#if DRAG
	vertexInput.Drag			= FetchDrag( nInstIndex );
#endif
#if DISTORTION && EFFECT3_MAP
	vertexInput.Distortion		= FetchDistortion( nInstIndex );
#endif

	return vertexInput;
}

#endif

// UV distortion mapping, precalculate our UV Distmap texcoords for the PS in the VS
float3 ComputeUVDistortionTexCoords( float2 inCoord, float2 distStrength, float4 distMapMod, float time, float lifeTime )
{
    // Sample our normal texcoord, scale it and determine current distortion stength value
    float3 distCoord		= float3( inCoord * distMapMod.z, lerp( distStrength.x, distStrength.y, lifeTime ) );

    // UV shift distortion map texcoords
    distCoord.xy			+= distMapMod.xy * time;
    
    // Rotate distortion map texcoord set
    float theta				= distMapMod.w * time;
    float s, c;
    sincos( theta, s, c );
    float2x2 R				= float2x2( c, s, -s, c );
    distCoord.xy			= mul( distCoord.xy - 0.5 * distMapMod.z, R ) + 0.5 * distMapMod.z;
    return distCoord;
}

float3 CalcInitialPosition( float4 Pos, float3 Acceleration, float3 dragCoeff, float3 Velocity, float elapsedTime, float Exp )
{
    // Initial position
#if DRAG
	return ( dragCoeff.z * Acceleration.xyz - dragCoeff.y * Velocity.xyz ) * ( Exp - 1 ) + dragCoeff.y * Acceleration.xyz * elapsedTime;
#else
	return Velocity.xyz * elapsedTime + (0.5f * Acceleration.xyz * (elapsedTime * elapsedTime)); 
#endif   
}

float2 CalcRotation( float2 corner, float startRot, float rotDelta, float elapsedTime )
{
	// Calculate the sin and cos of our rotation amount
	float rotcos, rotsin;

	// Rotate our initialze -1,1 quad around 0,0
	float2 rotatedquad;
	float rotationRadians	= startRot + (rotDelta * elapsedTime);
	sincos( rotationRadians, rotsin, rotcos );
	
	// Rotate the quad
	rotatedquad.x			= corner.x * rotcos - corner.y * rotsin;
	rotatedquad.y			= corner.x * rotsin + corner.y * rotcos;	
    return rotatedquad;
}

float3 CalcFlatFacing( float2 rotatedQuad, float2 size, float elapsedTime )
{
    // our right and up vectors are flat in worldspace
    return( float3( rotatedQuad.x, 0.0f, rotatedQuad.y ) * (size.x + (size.y * elapsedTime)) );
}

float3 CalcCameraFacing( float2 rotatedQuad, float2 size, float elapsedTime )
{
	// The view matrix gives us our right and up vectors.
	return( (rotatedQuad.x * TransposeViewX + rotatedQuad.y * TransposeViewY) * (size.x + (size.y * elapsedTime)) );
}

float2 ComputeAnimatedTexCoords( float framerate, float framesize, float2 texOffset, float2 texCoord, float elapsedTime )
{
	// calculate current texture frame
	float frame				= floor(framerate * elapsedTime);
	texCoord.x				*= framesize;
	texCoord.x				+= framesize * frame;
			
	// y offset of the texture for multiple frame types
	texCoord.y				*= texOffset.x;
	texCoord.y				+= texOffset.y;

    return texCoord;
}

float2 CalcRefractionTexCoords( float2 texCoord, float3 OutPos )
{
    texCoord				= 0.5 * OutPos.xy / OutPos.z + 0.5;
	texCoord.y				= 1 - texCoord.y; 
    return texCoord;
}

//////////////////////////////////////////////////////////////////////////////
// Vertex shader

ParticleVS_OUTPUT ParticleVS(
#ifndef XBOX
    ParticleVS_INPUT In
#else
    int index : INDEX
#endif
)
{
#ifdef XBOX
    ParticleVS_INPUT In		= CreateParticleVertexInput( index );
#endif 

	// Output from vertex shader
	ParticleVS_OUTPUT Out	= (ParticleVS_OUTPUT)0;
	
	// Calculate time variables associated with this particle
	float elapsed			= Time - In.Time.x;
	float lifetime			= elapsed / In.Time.y;

	// Calculate drag exponent
#if DRAG
	float dragExp			= pow( 2.71828183f, -In.Drag.x * elapsed );
#else
	float dragExp			= 0.0f;
#endif
		
	// Calculate initial position of this vertex
	float3 pos				= In.Position;
#if !NO_MOVEMENT
	pos						+= CalcInitialPosition( In.Position, In.Acceleration, In.Drag, In.Velocity.xyz, elapsed, dragExp );
#endif

	// Handle aligned rotation particles
#if ALIGN

	// Get the world space direction (accounting for drag, if requested)
#if DRAG
	float3 dir				= normalize( ( -In.Drag.y * In.Acceleration.xyz + In.Velocity.xyz ) * dragExp + In.Drag.y * In.Acceleration.xyz );
#else
	float3 dir				= normalize( In.Velocity.xyz + (In.Acceleration.xyz * elapsed) );
#endif

	// Calculate the offset vector for the particle by crossing it's direction with the direction of the camera
	float2 offsetScale		= In.Corner.xy * (In.Size.x + (In.Size.y * elapsed));
	pos						+= (normalize( cross( ViewDirection, dir ) ) * offsetScale.x) + (dir * offsetScale.y);

	// Handle standard facing particles
#else

	float2 rotatedquad		= CalcRotation( In.Corner, In.Position.w, In.Velocity.w, elapsed );

	// Billboard the quads.
#if FLAT
	pos						+= CalcFlatFacing( rotatedquad, In.Size.xy, elapsed );
#else
	pos						+= CalcCameraFacing( rotatedquad, In.Size.xy, elapsed );
#endif
#endif

	// Transform the position into homogenous clip space
	Out.Position			= mul( float4(pos, 1), ViewProj );
	
	// Build basic texture coordinates
	Out.TexCoord0			= (In.Corner.xy + 1) * 0.5f;
#if EFFECT2_MAP
	Out.TexCoord1			= float2( lifetime, In.TexOffset.y );
#endif
	
	// Compute distortion coordinates
#if DISTORTION && EFFECT3_MAP
	Out.TexCoord3			= ComputeUVDistortionTexCoords( Out.TexCoord0.xy, In.Size.zw, In.Distortion, elapsed, lifetime );
#endif	
		
	// Compute animated texture coordinates
#if ANIM
	Out.TexCoord0			= ComputeAnimatedTexCoords( In.Time.z, In.Time.w, In.TexOffset.zx, Out.TexCoord0.xy, elapsed );
#endif

	// Compute refraction coordinates
#if REFRACT
#if FLAT
	Out.ScreenCoord0		= float4( ComputeScreenCoords( Out.Position ), Out.Position.zw );
	float4 distBasis		= mul( float4(pos, 1) + float4( 0.1f, 0.0f, 0.1f, 0.0f ), ViewProj );
	Out.ScreenCoord1		= float4( ComputeScreenCoords( distBasis ), distBasis.zw );
#else
	Out.TexCoord2			= CalcRefractionTexCoords( Out.TexCoord2, Out.Position.xyw );
#endif
#endif
	
	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 ParticlePS( ParticleVS_OUTPUT In ) : COLOR
{
	// Our output color
	float2 texCoord			= In.TexCoord0;
	
#if DISTORTION && EFFECT3_MAP
	texCoord				+= tex2D( Effect3Map, In.TexCoord3.xy ).rg * In.TexCoord3.z;
#endif

	float4 Effect1Color		= float4( 0.0f, 0.0f, 0.0f, 0.0f );
	float4 Effect2Color		= float4( 1.0f, 1.0f, 1.0f, 1.0f );
	
#if EFFECT1_MAP
	Effect1Color			= tex2D( Effect1Map, texCoord );
#endif

#if EFFECT2_MAP
	Effect2Color			= tex2D( Effect2Map, In.TexCoord1 );
#endif

#if REFRACT
#if FLAT
	// Get the refraction texel using screen coordinates
	texCoord				= In.ScreenCoord0.xy / In.ScreenCoord0.w;
	texCoord				+= ((In.ScreenCoord1.xy / In.ScreenCoord1.w) - texCoord) * (2.0f * Effect1Color.rg - 1.0f);
#else
	texCoord				= In.TexCoord2 + (0.005f * ( 2.0f * Effect1Color.rg - 1.0f ));
#endif

	// Return refracted color
	return( float4( tex2D( RefractionMap, texCoord ).rgb, Effect1Color.a * Effect2Color.a ) );
#else
	
	// Return the finished color
	return( Effect1Color * Effect2Color );
#endif
}

//////////////////////////////////////////////////////////////////////////////
// Vertex input/output definitions

struct BeamVS_INPUT
{
	// Stream 0 static vertex data
	float3 Position			: POSITION0;
	float4 Size				: TEXCOORD0;
	float4 Color			: TEXCOORD1;
	float4 Scaling			: TEXCOORD2;
};

struct BeamVS_OUTPUT
{
	float4 Position			: POSITION;
	
	float4 Color			: COLOR0;
	float2 TexCoord0		: TEXCOORD0;
	float2 TexCoord1		: TEXCOORD1;
};


//////////////////////////////////////////////////////////////////////////////
// Vertex shader

BeamVS_OUTPUT BeamVS( BeamVS_INPUT In )
{
	// Output from vertex shader
	BeamVS_OUTPUT Out		= (BeamVS_OUTPUT)0;
	
	// Calculate the offset vector for the beam by crossing it's direction with the direction of the camera
	float3 offset			= normalize( cross( ViewDirection, In.Size.xyz ) ) * In.Size.w;

	// Calculate the transformed position
	Out.Position			= mul( float4( In.Position + offset, 1), ViewProj );

	// Build color and texture coords
	Out.Color				= In.Color;
	Out.TexCoord0			= In.Scaling.xy + (In.Scaling.zw * Time);
	Out.TexCoord1			= In.Scaling.xy;
	
	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 BeamPS( BeamVS_OUTPUT In ) : COLOR
{
	// Output color always includes input vertex color
	float4 OutColor			= In.Color;
	
#if EFFECT1_MAP
	OutColor				*= tex2D( Effect1Map, In.TexCoord0 );
#endif

#if EFFECT2_MAP
	OutColor				*= tex2D( Effect2Map, In.TexCoord1 );
#endif
	
	// Return the finished color
	return OutColor;
}

//////////////////////////////////////////////////////////////////////////////
// Vertex input/output definitions

struct TrailVS_INPUT
{
	// Stream 0 static vertex data
	float3 Position			: POSITION0;
	float3 Direction		: TEXCOORD0;
	float3 Lifetime			: TEXCOORD1;
	float4 Width			: TEXCOORD2;
};

struct TrailVS_OUTPUT
{
	float4 Position			: POSITION;
	
	float2 TexCoord0		: TEXCOORD0;
	float2 TexCoord1		: TEXCOORD1;
};


//////////////////////////////////////////////////////////////////////////////
// Vertex shader

TrailVS_OUTPUT TrailVS( TrailVS_INPUT In )
{
	// Output from vertex shader
	TrailVS_OUTPUT Out		= (TrailVS_OUTPUT)0;

	// Calculate the offset vector for the trail by crossing it's direction with the direction of the camera
	float3 offset			= normalize( cross( ViewDirection, In.Direction.xyz ) ) * In.Width.x;

	// get the position into projection space
	Out.Position			= mul( float4( In.Position + offset, 1 ), ViewProj );

	// output some useful uv's	
	Out.TexCoord0			= float2( In.Width.z, In.Lifetime.z );
	Out.TexCoord1			= float2( (Time - In.Lifetime.x) / In.Lifetime.y, In.Width.z );	
	
	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 TrailPS( TrailVS_OUTPUT In ) : COLOR
{
	// $$$ clip based on [0.0,1.0] value of In.TexCoord1.x?
	// Build the output color
	float4 OutColor			= float4( 0.0f, 0.0f, 0.0f, 0.0f );
	
#if EFFECT1_MAP
	OutColor				= tex2D( Effect1Map, In.TexCoord0 );
#endif

#if EFFECT2_MAP
	OutColor				*= tex2D( Effect2Map, In.TexCoord1 );
#endif
	
	// Return the finished color
	return OutColor;
}