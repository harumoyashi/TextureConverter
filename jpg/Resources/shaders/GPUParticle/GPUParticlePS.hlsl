#include "GPUParticle.hlsli"

Texture2D<float4> tex : register(t0);  // 0番スロットに設定されたテクスチャ
SamplerState smp : register(s0);      // 0番スロットに設定されたサンプラー

struct PSOutput
{
    float4 target0 : SV_TARGET0;
    float4 target1 : SV_TARGET1;
};

float4 main(GSOutput input) : SV_TARGET
{
    PSOutput output;
    
    // テクスチャマッピング
    float4 texcolor = tex.Sample(smp, input.uv);
    
    // 描画色 = テクスチャの色 * 指定された色
    float4 color = texcolor * input.color;
    
    return color;
}