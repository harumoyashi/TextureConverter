//定数バッファ用構造体
cbuffer ConstBufferDataMatrix : register(b0)
{
	matrix mat;
};

cbuffer ConstBufferDataColor : register(b1)
{
    float4 color; //色(RGBA)
};

//頂点データの出力構造体
//(頂点シェーダーからピクセルシェーダーへのやりとりに使用する)
struct VSOutput
{
	//システム用頂点座標
	float4 svpos:SV_POSITION;
	//uv値
	float2 uv:TEXCOORD;
};