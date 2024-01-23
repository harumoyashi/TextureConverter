#include "RadialBlur.hlsli"

Texture2D<float4> tex0 : register(t0); //0�ԃX���b�g�ɐݒ肳�ꂽ�e�N�X�`��
Texture2D<float4> tex1 : register(t1); //1�ԃX���b�g�ɐݒ肳�ꂽ�e�N�X�`��
SamplerState smp : register(s0); //0�ԃX���b�g�ɐݒ肳�ꂽ�T���v���[

float4 main(VSOutput input) : SV_TARGET
{
    float4 col;
    float _SampleCount = 10;    //���炵�����̉�
    float _Strength = 0.2f;     //���ꕝ
    
    // UV��-0.5�`0.5�ɕϊ�
    float2 symmetryUv = input.uv - 0.5;
    // �O���ɍs���قǂ��̒l���傫���Ȃ�
    float distance = length(symmetryUv);
    for (int j = 0; j < _SampleCount; j++)
    {
        // j���傫���قǁA��ʂ̊O���قǏ������Ȃ�l
        float uvOffset = 1 - _Strength * j / _SampleCount * distance;
        // j���傫���Ȃ�ɂ�Ă������̃s�N�Z�����T���v�����O���Ă���
        // �܂���ʂ̊O���قǂ������̃s�N�Z�����T���v�����O����
        col += tex0.Sample(smp,symmetryUv * uvOffset + 0.5);
    }
    col /= _SampleCount;
    return col;
}