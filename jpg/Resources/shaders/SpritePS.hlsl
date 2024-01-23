#include "Sprite.hlsli"

Texture2D<float4>tex : register(t0);	//0番スロットに設定されたテクスチャ
SamplerState smp : register(s0);	//0番スロットに設定されたサンプラー

struct PSOutput
{
    float4 target0 : SV_TARGET0;
    float4 target1 : SV_TARGET1;
};

PSOutput main(VSOutput input) : SV_TARGET
{
    PSOutput output;
    float4 col = (tex.Sample(smp, input.uv)) * color;
    
    output.target0 = col;
    output.target1 = col;
    return output; //定数バッファに送った色変えると反映される
}