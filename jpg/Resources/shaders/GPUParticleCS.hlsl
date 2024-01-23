#include "GPUParticle.hlsli"

struct Particle
{
    float3 pos : POSITION;          //システム用頂点座標
    float2 uv : TEXCOORD;           //uv値(ジオメトリシェーダーで設定するなら消すかも)
    float3 rot : ROT;               //回転情報
    float4 color : COLOR;           //色
    float scale : SCALE;            //スケール
    float startScale : STARTSCALE;  //開始時の大きさ
    float endScale : ENDSCALE;      //終了時の大きさ
    float3 plusRot : PULUSROT;      //更新処理で回転させるときに使う用
    float3 velo : VELOCITY;         //速度
    float3 accel : ACCEL;           //加速度
    bool isAlive : ALIVE;           //生存してるかフラグ
};

//RWStructuredBuffer:なんでも受け入れ可能な型。テンプレートみたいな
RWStructuredBuffer<Particle> particles;

//スレッド数を指定
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