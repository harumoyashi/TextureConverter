//定数バッファ用構造体
cbuffer ConstBufferDataMatrix : register(b0)
{
    matrix mat;
};

cbuffer ConstBufferDataColor : register(b1)
{
    float4 color; //色(RGBA)
};


struct VSOutput
{
    float4 svpos : SV_POSITION;
    float2 uv : TEXCOORD;
};