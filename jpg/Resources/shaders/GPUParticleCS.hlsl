#include "GPUParticle.hlsli"

struct Particle
{
    float3 pos : POSITION;          //�V�X�e���p���_���W
    float2 uv : TEXCOORD;           //uv�l(�W�I���g���V�F�[�_�[�Őݒ肷��Ȃ��������)
    float3 rot : ROT;               //��]���
    float4 color : COLOR;           //�F
    float scale : SCALE;            //�X�P�[��
    float startScale : STARTSCALE;  //�J�n���̑傫��
    float endScale : ENDSCALE;      //�I�����̑傫��
    float3 plusRot : PULUSROT;      //�X�V�����ŉ�]������Ƃ��Ɏg���p
    float3 velo : VELOCITY;         //���x
    float3 accel : ACCEL;           //�����x
    bool isAlive : ALIVE;           //�������Ă邩�t���O
};

//RWStructuredBuffer:�Ȃ�ł��󂯓���\�Ȍ^�B�e���v���[�g�݂�����
RWStructuredBuffer<Particle> particles;

//�X���b�h�����w��
[numthreads(256, 1, 1)]

void main(uint3 id : SV_DispatchThreadID)
{
    Particle p = particles[id.x];
    
    p.velo += p.accel;
    p.pos += p.velo;
    p.scale -= p.endScale;
    //p.isAlive = false;
    
    particles[id.x] = p;
}