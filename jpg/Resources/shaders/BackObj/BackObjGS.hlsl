#include "BackObj.hlsli"

//��x�ɂ����钸�_��
static const uint vnum = 3;

[maxvertexcount(15)] //���(�O�p) * 1 + ����(�l�p) * 3 = 15(��x�ɂ����钸�_��)
void main(
	triangle VSOutput input[3], //�|���S�����`������O�p�`���Ƃɏ��������
    uint pid : SV_PrimitiveID, //�e�v���~�e�B�u��ID(���ꂼ��̖ʂŉ����o������ς���������)
	inout TriangleStream<GSOutput> output
)
{
    GSOutput element; //�o�͗p���_�f�[�^
    
    //���[���h�s�񂩂�X�P�[���𒊏o
    float x = sqrt(pow(world[0][0], 2) + pow(world[0][1], 2) + pow(world[0][2], 2));
    float y = sqrt(pow(world[1][0], 2) + pow(world[1][1], 2) + pow(world[1][2], 2));
    float z = sqrt(pow(world[2][0], 2) + pow(world[2][1], 2) + pow(world[2][2], 2));
    
    float3 scale = { x, y, z };
    
    //------------- �O�p�`�̊e���_�̃��[���h���W��� -------------//
    float3 wpos[6]; //�����o���O�̎O�p�` + �����o������̎O�p�` = 6���_
    for (uint i = 0; i < vnum; i++)
    {
        wpos[i] = mul(world, float4(input[i].pos, 1)).xyz;
    }
    
    //------------- �O�p�`�̒��_��@�������ɉ����o�� -------------//
    //�����o����
    float extrusion = extrusionTimer[pid % 3] * 0.001f;
    extrusion *= sin(pid) * pid;
    
    //�O�p�`�̖@�������擾
    float3 triNormal = input[0].normal + input[1].normal + input[2].normal;
    //���̕����ɉ����o���ʂ��|�����I�t�Z�b�g���o��
    float3 offset = normalize(mul(world, float4(triNormal, 0))) * extrusion;
    //�����o�������W���擾
    for (uint j = vnum; j < 6; j++)
    {
        wpos[j] = wpos[j - vnum] + offset; //�����o���O�̒��_ + �I�t�Z�b�g
    }
            
    //------------- �����o������ʂƑ��ʂ̃v���~�e�B�u���o�͂��� -------------//   
    if (isAvoid)
    {
        //�����o���ꂽ��ʂ̎O�p�`
        for (uint k = vnum; k < 6; k++)
        {
            element.svpos = mul(viewproj, float4(wpos[k], 1));
            element.worldpos = float4(wpos[k], 1);
            element.normal = triNormal * saturate(wpos[k].xyz);
            element.uv = input[k - vnum].uv;
            element.scale = scale;
        
            output.Append(element);
        }
        
        //����
        for (uint l = 0; l < vnum; l++)
        {
            element.svpos = mul(viewproj, float4(wpos[l + 3], 1));
            element.worldpos = float4(wpos[l + 3], 1);
            element.normal = triNormal * saturate(wpos[l].xyz);
            element.uv = input[0].uv;
            element.scale = scale;
            output.Append(element);
            
            element.svpos = mul(viewproj, float4(wpos[l + 0], 1));
            element.worldpos = float4(wpos[l + 0], 1);
            element.normal = triNormal * saturate(wpos[l].xyz);
            element.uv = input[0].uv;
            element.scale = scale;
            output.Append(element);
            
            if (l < 2)
            {
                element.svpos = mul(viewproj, float4(wpos[l + 4], 1));
                element.worldpos = float4(wpos[l + 4], 1);
                element.normal = triNormal * saturate(wpos[l].xyz);
                element.uv = input[0].uv;
                element.scale = scale;
                output.Append(element);
            
                element.svpos = mul(viewproj, float4(wpos[l + 1], 1));
                element.worldpos = float4(wpos[l + 1], 1);
                element.normal = triNormal * saturate(wpos[l].xyz);
                element.uv = input[0].uv;
                element.scale = scale;
                output.Append(element);
            }
            else
            {
                element.svpos = mul(viewproj, float4(wpos[3], 1));
                element.worldpos = float4(wpos[3], 1);
                element.normal = triNormal * saturate(wpos[l].xyz);
                element.uv = input[0].uv;
                element.scale = scale;
                output.Append(element);
            
                element.svpos = mul(viewproj, float4(wpos[0], 1));
                element.worldpos = float4(wpos[0], 1);
                element.normal = triNormal * saturate(wpos[l].xyz);
                element.uv = input[0].uv;
                element.scale = scale;
                output.Append(element);
            }
        }
    }
    else
    {
        for (uint i = 0; i < 5; i++)
        {
            for (uint j = 0; j < vnum; j++)
            {
                element.svpos = mul(viewproj, float4(wpos[j], 1));
                element.worldpos = float4(wpos[j], 1);
                element.normal = triNormal * saturate(wpos[j].xyz);
                element.uv = input[j].uv;
                element.scale = scale;
                
                output.Append(element);
            }
        }
    }
}