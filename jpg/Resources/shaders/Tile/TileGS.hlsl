#include "Tile.hlsli"

//��x�ɂ����钸�_��
static const uint vnum = 3;

[maxvertexcount(vnum)]
void main(
	triangle VSOutput input[3], //�|���S�����`������O�p�`���Ƃɏ��������
    uint pid : SV_PrimitiveID, //�e�v���~�e�B�u��ID(���ꂼ��̖ʂłӂ�ӂ抴��ς���������)	
    inout TriangleStream<GSOutput> output
)
{
    GSOutput element; //�o�͗p���_�f�[�^
    
    for (uint i = 0; i < vnum; i++)
    {
        //���[���h�s�񂩂�X�P�[���𒊏o
        float x = sqrt(pow(world[0][0], 2) + pow(world[0][1], 2) + pow(world[0][2], 2));
        float y = sqrt(pow(world[1][0], 2) + pow(world[1][1], 2) + pow(world[1][2], 2));
        float z = sqrt(pow(world[2][0], 2) + pow(world[2][1], 2) + pow(world[2][2], 2));
    
        float3 scale = { x, y, z };
        
        //�r���[�A�ˉe�ϊ�
        //�I�u�W�F�N�g�ɋ߂��|���S���قǍ�����������
        float3 centerPos =
        (input[0].pos + input[1].pos + input[2].pos) / 3.f; //�|���S���̒��S�_
        centerPos = mul(world, float4(centerPos, 1)).xyz; //���[���h���W�ɒ���
        
        float3 objToPolyVec = { 0, 0, 0 }, plusVec = { 0, 0, 0 };
        float objToPolyDist = 0.f;
        for (uint j = 0; j < 1; j++)
        {
            float3 oPos = objPos[j];
            objToPolyVec = objPos[j] - centerPos; //�I�u�W�F�N�g�ƃ|���S���̒��S�_�Ƃ̃x�N�g��
            objToPolyDist = length(objToPolyVec); //�I�u�W�F�N�g�ƃ|���S���̒��S�_�Ƃ̋���
            objToPolyDist = clamp(objToPolyDist, 0.f, avoidArea); //�傫���Ȃ肷���Ȃ��悤��

            objToPolyDist = avoidArea - objToPolyDist; //�I�u�W�F�N�g�ɋ߂����傫���l��
            
            objToPolyVec = normalize(objToPolyVec);
            
            plusVec = objToPolyVec * objToPolyDist * 0.2f; //�ŏI�I�Ƀv���C���[����߂��قǉ�������x�N�g���𑫂�
            plusVec.y = -abs(objToPolyDist) * 0.1f;
        }
        
        //�����Ă�Ȃ炳��ɂӂ�ӂ悳����
        if (length(plusVec) > 0.f)
        {
            if (((pid % 5) + 1) > 3)
            {
                plusVec += (floatingTimer + (pid % 5) * 0.1f) * objToPolyVec * ((pid % 5) + 1) * 0.05f;
            }
            else
            {
                plusVec -= (floatingTimer + (pid % 5) * 0.1f) * objToPolyVec * ((pid % 5) + 1) * 0.05f;
            }
        }
        
        //�����ݒ肪true�̎��������W�Ƃ���]�����悤��(if��)
        plusVec *= isAvoid;
        
        //-------------------- ��] --------------------//
        //������]�x�N�g��
        float3 plusRot = plusVec * 3.14f;
        //Z����]�s��
        float sinZ = sin(plusRot.z);
        float cosZ = cos(plusRot.z);

        float4x4 matZ = float4x4(
        cosZ, sinZ, 0, 0,
        -sinZ, cosZ, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1);
        
        //X����]�s��
        float sinX = sin(plusRot.x);
        float cosX = cos(plusRot.x);

        float4x4 matX = float4x4(
        1, 0, 0, 0,
        0, cosX, sinX, 0,
        0, -sinX, cosX, 0,
        0, 0, 0, 1);
        
        //Y����]�s��
        float sinY = sin(plusRot.y);
        float cosY = cos(plusRot.y);

        float4x4 matY = float4x4(
        cosY, 0, sinY, 0,
        0, 1, 0, 0,
        -sinY, 0, cosY, 0,
        0, 0, 0, 1);
        
        //��]�s��|����
        //plusPos�����[���h���W��Ȃ̂ł��������Ȃ��Ă�
        float4 rotPos = float4(plusVec, 1);
        rotPos = mul(matZ, rotPos);
        rotPos = mul(matX, rotPos);
        rotPos = mul(matY, rotPos);
       
        //���[���h���W
        float4 wpos = mul(world, float4(input[i].pos, 1));
        //plusVec�����[���h���W������烏�[���h���W�ɒ��������̂ɑ���
        float3 plusPos = wpos.xyz + plusVec;
            
        //�@���Ƀ��[���h�s��ɂ��X�P�[�����O�E��]��K�p
        float4x4 rotMat = world;
        rotMat = mul(matZ, rotMat);
        rotMat = mul(matX, rotMat);
        rotMat = mul(matY, rotMat);
        float4 wnormal = normalize(mul(rotMat, float4(input[i].normal, 0)));
            
        //�������[���h���W�ɒ����Ă邩��V�X�e�����W�Ɋ|����̂̓r���[�s�񂾂�
        element.svpos = mul(viewproj, float4(plusPos, 1));
        element.worldpos = float4(plusPos, 1);
        element.normal = wnormal;
        element.uv = input[i].uv;
        element.scale = scale;
       
        output.Append(element);
    }
}