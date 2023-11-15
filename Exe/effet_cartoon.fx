// Paramètres
float4x4	matWorldViewProj;
float4x4	matInverseWorld;
float4		vLightDirection;
texture 	ColorMap;
texture 	CelMap;

// Sample associé à la texture
sampler ColorMapSampler = sampler_state
{
   Texture = <ColorMap>;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;   
};


// Sample associé à la texture "Cartoon"
sampler2D CelMapSampler = sampler_state
{
	Texture	  = <CelMap>;
	MIPFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MINFILTER = LINEAR;
};

// Structure du vertex shader
struct OUT
{
	float4 Pos	: POSITION;
	float2 Tex	: TEXCOORD0;
	float3 L	: TEXCOORD1;
	float3 N	: TEXCOORD2;
};

// Calcul de l'effet pour le vertex shader
OUT vs( float4 Pos: POSITION, float2 Tex : TEXCOORD, float3 N: NORMAL )
{
	OUT Out = (OUT) 0;
	Out.Pos = mul(Pos, matWorldViewProj);
	Out.Tex = Tex;
	Out.L = normalize(vLightDirection);
	Out.N = normalize(mul(matInverseWorld, N));
	
	return Out;
}

// Calcul de l'effet pour le pixel shader
float4 ps(float2 Tex: TEXCOORD0,float3 L: TEXCOORD1, float3 N: TEXCOORD2) : COLOR
{
	float4 Color = tex2D(ColorMapSampler, Tex);
	float Ai = 0.8f;
	float4 Ac = float4(0.2, 0.2, 0.2, 1.0);
	float Di = 1.0f;
	float4 Dc = float4(1.0, 1.0, 1.0, 1.0);
	
	Tex.y = 0.0f;
	Tex.x = saturate(dot(L, N));
	
	float4 CelColor = tex2D(CelMapSampler, Tex);	

	return (Ai*Ac*Color)+(Color*Di*CelColor);
}

// Effet
technique EffetCartoon
{
	pass P0
	{
		Sampler[0] = (ColorMapSampler);	
		Sampler[1] = (CelMapSampler);	
		
		VertexShader = compile vs_2_0 vs();
		PixelShader = compile ps_2_0 ps();
	}
}