#include "RadialBlur.hlsli"

Texture2D<float4> tex0 : register(t0); //0番スロットに設定されたテクスチャ
Texture2D<float4> tex1 : register(t1); //1番スロットに設定されたテクスチャ
SamplerState smp : register(s0); //0番スロットに設定されたサンプラー

float4 main(VSOutput input) : SV_TARGET
{
    float4 col;
    float _SampleCount = 10;    //ずらし処理の回数
    float _Strength = 0.2f;     //ずれ幅
    
    // UVを-0.5～0.5に変換
    float2 symmetryUv = input.uv - 0.5;
    // 外側に行くほどこの値が大きくなる
    float distance = length(symmetryUv);
    for (int j = 0; j < _SampleCount; j++)
    {
        // jが大きいほど、画面の外側ほど小さくなる値
        float uvOffset = 1 - _Strength * j / _SampleCount * distance;
        // jが大きくなるにつれてより内側のピクセルをサンプリングしていく
        // また画面の外側ほどより内側のピクセルをサンプリングする
        col += tex0.Sample(smp,symmetryUv * uvOffset + 0.5);
    }
    col /= _SampleCount;
    return col;
}