#include "Tile.hlsli"

float Clamp(float value, float min, float max)
{
    // 値が最大値を上回っていたら最大値を返す
    if (value >= max)
        return max;

	// 値が最小値を下回っていたら最小値を返す
    if (value <= min)
        return min;

	// どちらにも当てはまらなかったら値をそのまま返す
    return value;
};

//一度にいじる頂点数
static const uint vnum = 3;

[maxvertexcount(vnum)]
void main(
	triangle VSOutput input[3], //ポリゴンを形成する三角形ごとに処理される
	inout TriangleStream<GSOutput> output
)
{
    GSOutput element; //出力用頂点データ
    
    //ふよふよタイマー回す
    float floatingTimer = 0, maxFloatingTimer = 0;
    bool isTimerPlus = true; //タイマー足すか引くかフラグ
        
    if (maxFloatingTimer <= 0)
    {
        maxFloatingTimer = 120.f;
    }
        
    if (isTimerPlus)
    {
        floatingTimer++;
    }
    else
    {
        floatingTimer--;
    }
    
    if (isTimerPlus && floatingTimer >= maxFloatingTimer)
    {
        isTimerPlus = false;
    }
    else if (isTimerPlus == false && floatingTimer <= 0)
    {
        isTimerPlus = true;
    }
   
    for (uint i = 0; i < vnum; i++)
    {
        //ワールド行列からスケールを抽出
        float x = sqrt(pow(world[0][0], 2) + pow(world[0][1], 2) + pow(world[0][2], 2));
        float y = sqrt(pow(world[1][0], 2) + pow(world[1][1], 2) + pow(world[1][2], 2));
        float z = sqrt(pow(world[2][0], 2) + pow(world[2][1], 2) + pow(world[2][2], 2));
    
        float3 scale = { x, y, z };
        
        //ビュー、射影変換
        //オブジェクトに近いポリゴンほど高く浮く処理
        float3 centerPos =
        (input[0].pos + input[1].pos + input[2].pos) / 3.f; //ポリゴンの中心点
        centerPos = mul(world, float4(centerPos, 1)).xyz; //ワールド座標に直す
        
        float3 objToPolyVec, plusVec;
        float objToPolyDist;
        for (uint j = 0; j < 1; j++)
        {
            objToPolyVec = objPos[j] - centerPos; //オブジェクトとポリゴンの中心点とのベクトル
            objToPolyDist = length(objToPolyVec); //オブジェクトとポリゴンの中心点との距離
            objToPolyDist = Clamp(objToPolyDist, 0.f, avoidArea); //大きくなりすぎないように

            objToPolyDist = avoidArea - objToPolyDist; //オブジェクトに近い程大きい値に
            
            objToPolyVec = normalize(objToPolyVec);
            
            plusVec = objToPolyVec * objToPolyDist * 0.2f; //最終的にプレイヤーから近いほど遠ざかるベクトルを足す
            plusVec.y = -abs(objToPolyDist) * 0.1f;
        }
        
        ////浮いてるならさらにふよふよさせる
        //if (objToPolyDist > 0)
        //{
        //    plusVec += (floatingTimer / maxFloatingTimer) * objToPolyVec * 0.2f;
        //}
        
        //-------------------- 回転 --------------------//
        //足す回転ベクトル
        float3 plusRot = plusVec * 3.14f;
        //Z軸回転行列
        float sinZ = sin(plusRot.z);
        float cosZ = cos(plusRot.z);

        float4x4 matZ = float4x4(
        cosZ, sinZ, 0, 0,
        -sinZ, cosZ, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1);
        
        //X軸回転行列
        float sinX = sin(plusRot.x);
        float cosX = cos(plusRot.x);

        float4x4 matX = float4x4(
        1, 0, 0, 0,
        0, cosX, sinX, 0,
        0, -sinX, cosX, 0,
        0, 0, 0, 1);
        
        //Y軸回転行列
        float sinY = sin(plusRot.y);
        float cosY = cos(plusRot.y);

        float4x4 matY = float4x4(
        cosY, 0, sinY, 0,
        0, 1, 0, 0,
        -sinY, 0, cosY, 0,
        0, 0, 0, 1);
        
        //回転行列掛ける
        //plusPosがワールド座標基準なのでおかしくなってる
        float4 rotPos = float4(plusVec, 1);
        rotPos = mul(matZ, rotPos);
        rotPos = mul(matX, rotPos);
        rotPos = mul(matY, rotPos);
        
        if (isAvoid)
        {
            //ワールド座標
            float4 wpos = mul(world, float4(input[i].pos, 1));
            //plusVecがワールド座標基準だからワールド座標に直したものに足す
            float3 plusPos = wpos.xyz + plusVec;
            
            //法線にワールド行列によるスケーリング・回転を適用
            float4x4 rotMat = world;
            rotMat = mul(matZ, rotMat);
            rotMat = mul(matX, rotMat);
            rotMat = mul(matY, rotMat);
            float4 wnormal = normalize(mul(rotMat, float4(input[i].normal, 0)));
            
            //もうワールド座標に直してるからシステム座標に掛けるのはビュー行列だけ
            element.svpos = mul(viewproj, float4(plusPos, 1));
            element.worldpos = float4(plusPos, 1);
            element.normal = wnormal;
            element.uv = input[i].uv;
            element.scale = scale;
        }
        else
        {
            //ワールド座標
            float4 wpos = mul(world, float4(input[i].pos, 1));
            
            element.svpos = mul(viewproj, wpos);
            element.worldpos = wpos;
            element.normal = input[i].normal;
            element.uv = input[i].uv;
            element.scale = scale;
        }
        
        output.Append(element);
    }
}