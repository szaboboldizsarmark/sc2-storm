//////////////////////////////////////////////////////////////////////////////
//
// Global constants are defined in global_constants.hlsl
//
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Textures/Samplers used by this shader

sampler2D SourceMap;
sampler2D FogOfWarSourceMap;
sampler2D ResultMap;
sampler3D ColorCorrect1;
sampler3D ColorCorrect2;
sampler3D FogCorrect;
sampler2D DepthOfField;


//////////////////////////////////////////////////////////////////////////////
// Vertex input/output definitions

struct VS_INPUT
{
	float4 Position			: POSITION;
	float2 TexCoord			: TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 Position			: POSITION;
    float2 TexCoord			: TEXCOORD0;
};


//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VS_OUTPUT FrameVS( VS_INPUT In )
{
	// Output from vertex shader
	VS_OUTPUT Out			= (VS_OUTPUT)0;

	// Build output position
	Out.Position			= In.Position;
	Out.TexCoord			= In.TexCoord;

	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 FramePS( VS_OUTPUT In ) : COLOR
{
	return GlobalColor;
}


#ifdef SAMPLES

//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VS_OUTPUT GaussianVS( VS_INPUT In )
{
	// Output from vertex shader
	VS_OUTPUT Out			= (VS_OUTPUT)0;

	// Build output position
	Out.Position			= In.Position;
	Out.TexCoord			= In.TexCoord + ScreenTexOffset;

	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 GaussianPS( VS_OUTPUT In ) : COLOR
{
	float4 OutColor			= float4( 0.0f, 0.0f, 0.0f, 0.0f );

	for( int i = 0; i < SAMPLES; ++i )
	{
#if OFFSET_WEIGHTS
		float4 color		= tex2D( SourceMap, GaussianSamples[i+SAMPLES].xy + In.TexCoord );
#else
		float4 color		= tex2D( SourceMap, GaussianSamples[i].yz + In.TexCoord );
#endif

#if PREMULTIPLIED_ALPHA
		color.rgb			*= color.a;
#endif

#if OFFSET_WEIGHTS
		OutColor			+= GaussianSamples[i] * color;
#else
		OutColor			+= GaussianSamples[i].x * color;
#endif
	}
	
#if THRESHOLD
	OutColor.rgb			*= max( 0.0f, (OutColor.a - BloomValues.x) ) * BloomValues.y;
#endif

#if SCALE
	OutColor				*= BloomValues.y;
#endif

#if ADD_RESULT
	OutColor				+= tex2D( ResultMap, In.TexCoord );
#endif
	
	return OutColor;
}

#endif

//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VS_OUTPUT BloomVS( VS_INPUT In )
{
	// Output from vertex shader
	VS_OUTPUT Out			= (VS_OUTPUT)0;

	// Build output position
	Out.Position			= In.Position;
	Out.TexCoord			= In.TexCoord + ScreenTexOffset;

	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 BloomPS( VS_OUTPUT In ) : COLOR
{
#if ADD_RESULT
	return( tex2D( SourceMap, In.TexCoord ) * BloomValues.x +
			tex2D( ResultMap, In.TexCoord ) * BloomValues.y );
#else
	return( tex2D( SourceMap, In.TexCoord ) * BloomValues.x );
#endif
}

//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VS_OUTPUT ColorCorrectVS( VS_INPUT In )
{
	// Output from vertex shader
	VS_OUTPUT Out			= (VS_OUTPUT)0;

	// Build output position
	Out.Position			= In.Position;
	Out.TexCoord			= In.TexCoord + ScreenTexOffset;

	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 ColorCorrectPS( VS_OUTPUT In ) : COLOR
{
	// Sample the screen color prior to correction
	float4 screenColor		= tex2D( SourceMap, In.TexCoord );
	
#if FOG || DEPTH_OF_FIELD
	float2 depthFoW			= tex2D( FogOfWarSourceMap, In.TexCoord ).rg;
#endif

#if DEPTH_OF_FIELD
	float4 blurredColor		= tex2D( DepthOfField, In.TexCoord );
	screenColor				= lerp( blurredColor, screenColor, SharpenValues.z + (saturate( (depthFoW.r - SharpenValues.x) * SharpenValues.y ) * SharpenValues.w) );
	screenColor				= lerp( screenColor, blurredColor, saturate( (depthFoW.r - DepthOfFieldValues.x) * DepthOfFieldValues.y ) );
#endif
	
#if COLOR_CORRECT1_MAP
	float4 correctColor		= float4( tex3D( ColorCorrect1, screenColor.rgb ).rgb, screenColor.a );
#else
	float4 correctColor		= screenColor;
#endif

#if FOG
#if FOG_CORRECT_MAP
	float4 fogColor			= float4( tex3D( FogCorrect, screenColor.rgb ).rgb, screenColor.a );
#else
	float4 fogColor			= screenColor * float4( 0.67f, 0.67f, 0.67f, 1.0f );
#endif

	return( lerp( fogColor, correctColor, depthFoW.g ) );
#else

	return( correctColor );
#endif
}

//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VS_OUTPUT RangeBlendVS( VS_INPUT In )
{
	// Output from vertex shader
	VS_OUTPUT Out			= (VS_OUTPUT)0;

	// Build output position
	Out.Position			= In.Position;
	Out.TexCoord			= In.TexCoord + ScreenTexOffset;

	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

float4 RangeBlendPS( VS_OUTPUT In ) : COLOR
{
	return tex2D( SourceMap, In.TexCoord );
}


#ifdef XBOX

//////////////////////////////////////////////////////////////////////////////
// Vertex shader

VS_OUTPUT DownsampleDepthVS( VS_INPUT In )
{
	// Output from vertex shader
	VS_OUTPUT Out			= (VS_OUTPUT)0;

	// Build output position
	Out.Position			= In.Position;
	Out.TexCoord			= In.TexCoord + ScreenTexOffset;

	// Return our finished product
	return Out;
}


//////////////////////////////////////////////////////////////////////////////
// Pixel shader

void DownsampleDepthPS( in float2 vTexCoord : TEXCOORD0,
                        out float4 oColor   : COLOR,
                        out float oDepth    : DEPTH )
{
	// Fetch the four samples
	float4 SampledDepth;
	asm {
		tfetch2D SampledDepth.x___, vTexCoord, SourceMap, OffsetX = -0.5, OffsetY = -0.5
		tfetch2D SampledDepth._x__, vTexCoord, SourceMap, OffsetX =  0.5, OffsetY = -0.5
		tfetch2D SampledDepth.__x_, vTexCoord, SourceMap, OffsetX = -0.5, OffsetY =  0.5
		tfetch2D SampledDepth.___x, vTexCoord, SourceMap, OffsetX =  0.5, OffsetY =  0.5
	};

	// Find the maximum.
	SampledDepth.xy = max( SampledDepth.xy, SampledDepth.zw );
	SampledDepth.x = max( SampledDepth.x, SampledDepth.y );

	oColor = SampledDepth.x;
	oDepth = SampledDepth.x;
}

#endif