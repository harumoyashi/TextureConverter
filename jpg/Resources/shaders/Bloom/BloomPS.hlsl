#include "Bloom.hlsli"

Texture2D<float4> tex0 : register(t0); //0�ԃX���b�g�ɐݒ肳�ꂽ�e�N�X�`��
SamplerState smp : register(s0); //0�ԃX���b�g�ɐݒ肳�ꂽ�T���v���[

//���P�x���o
float4 ExtractLuminance(float2 uv)
{
    float4 col = tex0.Sample(smp, uv);
    float grayScale = col.r * 0.299f + col.g * 0.587f + col.b * 0.114f; //�����ɂ���
    float extract = smoothstep(0.4f, 0.9f, grayScale);                  //���Â��͂����肳����
    return col * extract;                                               //���摜�̖��邢�����������c��悤��
}

float Gaussian(float2 drawUV, float2 pickUV, float sigma)
{
    float d = distance(drawUV, pickUV);
    return exp(-(d * d) / (2.0f * sigma * sigma));
}

float4 Blur(float2 uv)
{
	//�K�E�V�A���u���[//
    float totalWeight = 0.f, _Sigma = 0.002f, _StepWidth = 0.001f; //Bloom�̓u���[��傰����
    float4 blurCol = float4(0, 0, 0, 0);

    for (float py = -_Sigma * 4.0f; py <= _Sigma * 4.0f; py += _StepWidth)
    {
        for (float px = -_Sigma * 2.0f; px <= _Sigma * 2.0f; px += _StepWidth)
        {
            float2 pickUV = uv + float2(px, py);
            float weight = Gaussian(uv, pickUV, _Sigma);
            blurCol += ExtractLuminance(pickUV) * weight; //Gaussian�Ŏ擾�����u�d�݁v��F�ɂ�����
            totalWeight += weight; //�������u�d�݁v�̍��v�l���T���Ƃ�
        }
    }
    blurCol.rgb = blurCol.rgb / totalWeight; //�������u�d�݁v���A���ʂ��犄��
    
    return blurCol;
}

float4 main(VSOutput input) : SV_TARGET
{
    float4 texcolor = tex0.Sample(smp, input.uv);
    float4 blurTexCol = Blur(input.uv);
    return texcolor + blurTexCol;
}