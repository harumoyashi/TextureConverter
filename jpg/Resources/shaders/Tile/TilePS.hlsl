#include "Tile.hlsli"

Texture2D<float4> tex : register(t0); // 0�ԃX���b�g�ɐݒ肳�ꂽ�e�N�X�`��
SamplerState smp : register(s0); // 0�ԃX���b�g�ɐݒ肳�ꂽ�T���v���[

struct PSOutput
{
    float4 target0 : SV_TARGET0;
    float4 target1 : SV_TARGET1;
};

PSOutput main(GSOutput input) : SV_TARGET
{
    PSOutput output;
    
	// �e�N�X�`���}�b�s���O
    float4 texcolor = tex.Sample(smp, input.uv * float2(input.scale.x / divide, input.scale.z / divide));
    if (activityArea < input.worldpos.x || -activityArea > input.worldpos.x)
    {
        texcolor = float4(1.0f - texcolor.rgb - 0.9f, texcolor.a);
    }
    texcolor.rgb *= 0.8f;   //�Â߂ɂ���
    
	// ����x
        const float shininess = 4.0f;
	// ���_���王�_�ւ̕����x�N�g��
    float3 eyedir = normalize(cameraPos - input.worldpos.xyz);
	
	// �����ˌ�
    float3 ambient = m_ambient * ambientColor;
    
	// �V�F�[�f�B���O�ɂ��F
    float4 shadecolor = float4(ambient, m_color.a);
	
    //���s����
    for (uint i = 0; i < DIRLIGHT_NUM; i++)
    {
        if (dirLights[i].active)
        {
            // ���C�g�Ɍ������x�N�g���Ɩ@���̓���
            float3 dotlightnormal = dot(dirLights[i].lightv, input.normal);
	        // ���ˌ��x�N�g��
            float3 reflect = normalize(-dirLights[i].lightv + 2 * dotlightnormal * input.normal);
            // �g�U���ˌ�
            float3 diffuse = dotlightnormal * m_diffuse;
	        // ���ʔ��ˌ�
            float3 specular = pow(saturate(dot(reflect, eyedir)), shininess) * m_specular;
	        // �S�ĉ��Z����
            shadecolor.rgb += (diffuse + specular) * dirLights[i].lightcolor;
        }
    }
    
     //�_����
    for (uint j = 0; j < POINTLIGHT_NUM; j++)
    {
        if (pointLights[j].active)
        {
            // ���C�g�̃x�N�g��
            float3 lightv = pointLights[j].lightpos - input.worldpos.xyz;
            //�x�N�g���̒���
            float d = length(lightv);
            //���K�����A�P�ʃx�N�g���ɂ���
            lightv = normalize(lightv);
            //���������W��
            float atten = 1.0f / (pointLights[j].lightatten.x + pointLights[j].lightatten.y * d +
            pointLights[j].lightatten.z * d * d);
            // ���C�g�Ɍ������x�N�g���Ɩ@���̓���
            float3 dotlightnormal = dot(lightv, input.normal);
	        // ���ˌ��x�N�g��
            float3 reflect = normalize(-lightv + 2 * dotlightnormal * input.normal);
            // �g�U���ˌ�
            float3 diffuse = dotlightnormal * m_diffuse;
	        // ���ʔ��ˌ�
            float3 specular = pow(saturate(dot(reflect, eyedir)), shininess) * m_specular;
	        // �S�ĉ��Z����
            shadecolor.rgb += atten * (diffuse + specular) * pointLights[j].lightcolor;
        }
    }
    
    //�X�|�b�g���C�g
    for (uint k = 0; k < SPOTLIGHT_NUM; k++)
    {
        if (spotLights[k].active)
        {
            // ���C�g�̃x�N�g��
            float3 lightv = spotLights[k].lightpos - input.worldpos.xyz;
            //�x�N�g���̒���
            float d = length(lightv);
            //���K�����A�P�ʃx�N�g���ɂ���
            lightv = normalize(lightv);
            //���������W��
            float atten = saturate(1.0f / (spotLights[k].lightatten.x + spotLights[k].lightatten.y * d +
            spotLights[k].lightatten.z * d * d));
            //�p�x����
            float cos = dot(lightv, spotLights[k].lightv);
            //�����J�n�p�x���猸���I���p�x�ɂ����Č���
            //�����J�n�p�x�̓�����1�{�@�����I���p�x�̊O����0�{�̋P�x
            float angleatten = smoothstep(spotLights[k].lightfactoranglecos.y, spotLights[k].lightfactoranglecos.x, cos);
            //�p�x��������Z
            atten *= angleatten;
            // ���C�g�Ɍ������x�N�g���Ɩ@���̓���
            float3 dotlightnormal = dot(lightv, input.normal);
	        // ���ˌ��x�N�g��
            float3 reflect = normalize(-lightv + 2 * dotlightnormal * input.normal);
            // �g�U���ˌ�
            float3 diffuse = dotlightnormal * m_diffuse;
	        // ���ʔ��ˌ�
            float3 specular = pow(saturate(dot(reflect, eyedir)), shininess) * m_specular;
	        // �S�ĉ��Z����
            shadecolor.rgb += atten * (diffuse + specular) * spotLights[k].lightcolor;
        }
    }
    
    //�ۉe
    for (uint l = 0; l < CIRCLESHADOW_NUM; l++)
    {
        if (circleShadows[l].active)
        {
            //�I�u�W�F�N�g�\�ʂ���L���X�^�[�ւ̃x�N�g��
            float3 casterv = circleShadows[l].casterPos - input.worldpos.xyz;
            //���e�����ł̋���
            float d = dot(casterv, circleShadows[l].dir);
            //���������W��
            float atten = saturate(1.0f / (circleShadows[l].atten.x + circleShadows[l].atten.y * d +
            circleShadows[i].atten.z * d * d));
            //�������}�C�i�X�Ȃ�0�ɂ���
            atten *= step(0, d);
            //���z���C�g�̍��W
            float3 lightpos = circleShadows[l].casterPos + circleShadows[l].dir * circleShadows[l].distanceCasterLight;
            //�I�u�W�F�N�g�\�ʂ��烉�C�g�ւ̃x�N�g��(�P�ʃx�N�g��)
            float3 lightv = normalize(lightpos - input.worldpos.xyz);
            //�p�x����
            float cos = dot(lightv, circleShadows[l].dir);
            //�����J�n�p�x���猸���I���p�x�ɂ����Č���
            //�����J�n�p�x�̓�����1�{�@�����I���p�x�̊O����0�{�̋P�x
            float angleatten = smoothstep(circleShadows[l].factoranglecos.y, circleShadows[l].factoranglecos.x, cos);
            //�p�x��������Z
            atten *= angleatten;
	        // �S�Č��Z����
            shadecolor.rgb -= atten;
        }
    }

    
    // �V�F�[�f�B���O�F�ŕ`��
    float4 color = shadecolor * texcolor * m_color;
    output.target0 = color;
    output.target1 = color;
    return output;
}