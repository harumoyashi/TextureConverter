cbuffer cbuff0 : register(b0)
{
    float3 m_ambient : packoffset(c0);  // �A���r�G���g�W��
    float3 m_diffuse : packoffset(c1);  // �f�B�t���[�Y�W��
    float3 m_specular : packoffset(c2); // �X�y�L�����[�W��
}

cbuffer cbuff1 : register(b1)
{
    float4 m_color;
}

cbuffer cbuff2 : register(b2)
{
    matrix viewproj;    // �r���[�v���W�F�N�V�����s��
    matrix world;       // ���[���h�s��
    float3 cameraPos;   // �J�������W(���[���h���W)
};

//���s�����̐�
static const int DIRLIGHT_NUM = 3;

//���s����
struct DirLight
{
    float3 lightv; //���C�g�ւ̕����̒P�ʃx�N�g��
    float3 lightcolor; //���C�g�̐F(RGB)
    uint active;
};

//�_�����̐�
static const int POINTLIGHT_NUM = 3;

//�_����
struct PointLight
{
    float3 lightpos; //���C�g���W
    float3 lightcolor; //���C�g�̐F(RGB)
    float3 lightatten; //���C�g�̋��������W��
    uint active;
};

//�X�|�b�g���C�g�̐�
static const int SPOTLIGHT_NUM = 3;

//�X�|�b�g���C�g
struct SpotLight
{
    float3 lightv; //���C�g�̌��������̋t�x�N�g��
    float3 lightpos; //���C�g���W
    float3 lightcolor; //���C�g�̐F(RGB)
    float3 lightatten; //���C�g�̋��������W��
    float2 lightfactoranglecos; //���C�g�̋��������p�x�̃R�T�C��
    uint active;
};

//�ۉe�̐�
static const int CIRCLESHADOW_NUM = 1;

//�ۉe
struct CircleShadow
{
    float3 dir; //���e�����̋t�x�N�g��
    float3 casterPos; //���C�g���W
    float distanceCasterLight; //�L���X�^�[�ƃ��C�g�̋���
    float3 atten; //���������W��
    float2 factoranglecos; //�����p�x�̃R�T�C��
    uint active;
};

cbuffer cbuff3 : register(b3)
{
    float3 ambientColor;
    DirLight dirLights[DIRLIGHT_NUM];
    PointLight pointLights[POINTLIGHT_NUM];
    SpotLight spotLights[SPOTLIGHT_NUM];
    CircleShadow circleShadows[CIRCLESHADOW_NUM];
};

cbuffer cbuff4 : register(b4)
{
    bool isAvoid;
    float extrusionTimer;
}

// ���_�V�F�[�_�[����s�N�Z���V�F�[�_�[�ւ̂����Ɏg�p����\����
struct VSInput
{
    float3 pos : POSITION;  // �V�X�e���p���_���W
    float3 normal : NORMAL; // �@���x�N�g��
    float2 uv : TEXCOORD;   // uv�l
};

struct VSOutput
{
    float3 pos : POSITION;  // �V�X�e���p���_���W
    float3 normal : NORMAL; // �@���x�N�g��
    float2 uv : TEXCOORD;   // uv�l
};

struct GSOutput
{
    float4 svpos : SV_POSITION;     // �V�X�e���p���_���W
    float4 worldpos : POSITION;     // ���[���h���W
    float3 normal : NORMAL;         // �@���x�N�g��
    float2 uv : TEXCOORD;           // uv�l
    float3 scale : SCALE;           // �s�񂩂甲���o�����X�P�[��
};
