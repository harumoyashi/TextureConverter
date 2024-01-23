#include "ParticlePolygon.hlsli"

//�l�p�`�̒��_��
static const uint vnum = 3;

//�Z���^�[����̃I�t�Z�b�g
static const float4 offset_array[vnum] =
{
    float4(-0.5f, -0.5f, -0.5f, 0), //����
    float4(-0.5f, +0.5f, -0.5f, 0), //����
    float4(+0.5f, +0.5f, -0.5f, 0), //�E��
};

//���オ0,0�@�E����1,1
static const float2 uv_array[vnum] =
{
    float2(0.0f, 1.0f), //����
    float2(0.0f, 0.0f), //����
    float2(1.0f, 0.0f), //�E��
};

static const float3 normal_array[vnum] =
{
    float3(0.0f, 0.0f, -1.0f), //����
    float3(0.0f, 0.0f, -1.0f), //����
    float3(0.0f, 0.0f, -1.0f), //�E��
};

[maxvertexcount(vnum)]
void main(
	point VSOutput input[1],
	inout TriangleStream<GSOutput> output
)
{
    GSOutput element; //�o�͗p���_�f�[�^
   
    for (uint i = 0; i < vnum; i++)
    {
        //���S����̃I�t�Z�b�g���X�P�[�����O
        float4 offset = offset_array[i] * input[0].scale;
        
        //Z����]�s��
        float sinZ = sin(input[0].rot.z);
        float cosZ = cos(input[0].rot.z);

        float4x4 matZ = float4x4(
        cosZ, sinZ, 0, 0,
        -sinZ, cosZ, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1);
        
        //X����]�s��
        float sinX = sin(input[0].rot.x);
        float cosX = cos(input[0].rot.x);

        float4x4 matX = float4x4(
        1, 0, 0, 0,
        0, cosX, sinX, 0,
        0, -sinX, cosX, 0,
        0, 0, 0, 1);
        
        //Y����]�s��
        float sinY = sin(input[0].rot.y);
        float cosY = cos(input[0].rot.y);

        float4x4 matY = float4x4(
        cosY, 0, sinY, 0,
        0, 1, 0, 0,
        -sinY, 0, cosY, 0,
        0, 0, 0, 1);
        
        offset = mul(matZ, offset);
        offset = mul(matX, offset);
        offset = mul(matY, offset);
        
        float4x4 rotMat = world;
        rotMat = mul(matZ, rotMat);
        rotMat = mul(matX, rotMat);
        rotMat = mul(matY, rotMat);
        
        //�V�X�e���p���_���W
        //�I�t�Z�b�g�����炷(���[���h���W)
        float4 svpos = input[0].pos + offset;
        
        //�r���[�A�ˉe�ϊ�
        svpos = mul(viewproj, svpos);
        float4 wpos = mul(world, input[0].pos + offset);
        element.svpos = svpos;
        element.worldpos = wpos;
        element.color = input[0].color;
        float4 wnormal = normalize(mul(rotMat, float4(normal_array[i], 0)));
        element.normal = wnormal.xyz;
        element.uv = uv_array[i];
        
        output.Append(element);
    }
}