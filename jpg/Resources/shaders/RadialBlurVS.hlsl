#include "RadialBlur.hlsli"

VSOutput main(float3 pos : SV_POSITION, float2 uv : TEXCOORD)
{
    VSOutput output; //ピクセルシェーダーに渡す値
    output.svpos = mul(mat, float4(pos, 1));
    output.uv = uv;
    return output;
}