cbuffer cbuff0 : register(b0)
{
    matrix viewproj;    // ビュープロジェクション行列
    matrix world;       // ワールド行列
    float3 cameraPos;   // カメラ座標(ワールド座標)
};

struct VSInput
{
    float4 pos : POSITION; //システム用頂点座標
    float2 uv : TEXCOORD; //uv値(ジオメトリシェーダーで設定するなら消すかも)
    float3 rot : ROT; //回転情報
    float4 color : COLOR; //色
    float scale : SCALE; //スケール
};
	
// 頂点シェーダーからピクセルシェーダーへのやり取りに使用する構造体
struct VSOutput
{
    float4 pos : SV_POSITION;          //システム用頂点座標
    float2 uv : TEXCOORD;           //uv値(ジオメトリシェーダーで設定するなら消すかも)
    float3 rot : ROT;               //回転情報
    float4 color : COLOR;           //色
    float scale : SCALE;            //スケール
    float startScale : STARTSCALE;  //開始時の大きさ
    float endScale : ENDSCALE;      //終了時の大きさ
    float3 plusRot : PLUSROT;       //更新処理で回転させるときに使う用
    float3 velo : VELOCITY;         //速度
    float3 accel : ACCEL;           //加速度
    bool isAlive : ALIVE;           //生存してるかフラグ
};

struct GSOutput
{
    float4 svpos : SV_POSITION; //システム用頂点座標
    float4 worldpos : POSITION; //ワールド座標
    float4 color : COLOR;       //色
    float2 uv : TEXCOORD;       //uv値
};
