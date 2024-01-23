#include "Bloom.hlsli"

Texture2D<float4> tex0 : register(t0); //0番スロットに設定されたテクスチャ
SamplerState smp : register(s0); //0番スロットに設定されたサンプラー

//高輝度抽出
float4 ExtractLuminance(float2 uv)
{
    float4 col = tex0.Sample(smp, uv);
    float grayScale = col.r * 0.299f + col.g * 0.587f + col.b * 0.114f; //白黒にして
    float extract = smoothstep(0.4f, 0.9f, grayScale);                  //明暗をはっきりさせて
    return col * extract;                                               //元画像の明るい部分だけが残るように
}

float Gaussian(float2 drawUV, float2 pickUV, float sigma)
{
    float d = distance(drawUV, pickUV);
    return exp(-(d * d) / (2.0f * sigma * sigma));
}

float4 Blur(float2 uv)
{
	//ガウシアンブラー//
    float totalWeight = 0.f, _Sigma = 0.002f, _StepWidth = 0.001f; //Bloomはブラーを大げさに
    float4 blurCol = float4(0, 0, 0, 0);

    for (float py = -_Sigma * 4.0f; py <= _Sigma * 4.0f; py += _StepWidth)
    {
        for (float px = -_Sigma * 2.0f; px <= _Sigma * 2.0f; px += _StepWidth)
        {
            float2 pickUV = uv + float2(px, py);
            float weight = Gaussian(uv, pickUV, _Sigma);
            blurCol += ExtractLuminance(pickUV) * weight; //Gaussianで取得した「重み」を色にかける
            totalWeight += weight; //かけた「重み」の合計値を控えとく
        }
    }
    blurCol.rgb = blurCol.rgb / totalWeight; //かけた「重み」分、結果から割る
    
    return blurCol;
}

float4 main(VSOutput input) : SV_TARGET
{
    float4 texcolor = tex0.Sample(smp, input.uv);
    float4 blurTexCol = Blur(input.uv);
    return texcolor + blurTexCol;
}