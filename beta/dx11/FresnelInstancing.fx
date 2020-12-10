//@author: vux
//@help: template for standard shaders
//@tags: template
//@credits: 

Texture2D texture2d <string uiname="Texture";>;

SamplerState linearSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : LAYERVIEWPROJECTION;	
	float4x4 tVI : VIEWINVERSE;
	
	float Exp = 3.0;
};

StructuredBuffer<float4> PositionBuffer;
StructuredBuffer<float4> ColorBuffer;

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;
	float3 Normal : NORMAL;
	uint iid : SV_InstanceID;
};

struct vs2ps
{
    float4 PosWVP: SV_Position;
    float4 TexCd: TEXCOORD0;
	float3 posW : POSITION_WS;
	float3 Normal : NORMAL;
	uint iid : IID;
};

vs2ps VS(VS_IN input)
{
    vs2ps output;
	float4 posW = input.PosO + PositionBuffer[input.iid];
    output.PosWVP  = mul(posW,mul(tW,tVP));
	output.posW = posW.xyz;
    output.TexCd = input.TexCd;
	output.iid = input.iid;
	output.Normal = input.Normal;
    return output;
}




float4 PS(vs2ps In): SV_Target
{
	float3 norm = In.Normal;
	float3 eye = tVI[3].xyz;
	float3 posW = In.posW;
	
	float3 eyeDir = normalize(eye - posW);
	float d = dot(norm, eyeDir);
	
    return ColorBuffer[In.iid] * saturate(pow(1 - d, Exp));
}





technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




