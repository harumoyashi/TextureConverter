#include "Sprite.hlsli"

Texture2D<float4>tex : register(t0);	//0�ԃX���b�g�ɐݒ肳�ꂽ�e�N�X�`��
SamplerState smp : register(s0);	//0�ԃX���b�g�ɐݒ肳�ꂽ�T���v���[

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
    return output; //�萔�o�b�t�@�ɑ������F�ς���Ɣ��f�����
}