//�萔�o�b�t�@�p�\����
cbuffer ConstBufferDataMatrix : register(b0)
{
    matrix mat;
};

cbuffer ConstBufferDataColor : register(b1)
{
    float4 color; //�F(RGBA)
};


struct VSOutput
{
    float4 svpos : SV_POSITION;
    float2 uv : TEXCOORD;
};