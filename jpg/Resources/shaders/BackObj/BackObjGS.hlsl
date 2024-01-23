#include "BackObj.hlsli"

//一度にいじる頂点数
static const uint vnum = 3;

[maxvertexcount(15)] //上面(三角) * 1 + 側面(四角) * 3 = 15(一度にいじる頂点数)
void main(
	triangle VSOutput input[3], //ポリゴンを形成する三角形ごとに処理される
    uint pid : SV_PrimitiveID, //各プリミティブのID(それぞれの面で押し出し方を変えたいから)
	inout TriangleStream<GSOutput> output
)
{
    GSOutput element; //出力用頂点データ
    
    //ワールド行列からスケールを抽出
    float x = sqrt(pow(world[0][0], 2) + pow(world[0][1], 2) + pow(world[0][2], 2));
    float y = sqrt(pow(world[1][0], 2) + pow(world[1][1], 2) + pow(world[1][2], 2));
    float z = sqrt(pow(world[2][0], 2) + pow(world[2][1], 2) + pow(world[2][2], 2));
    
    float3 scale = { x, y, z };
    
    //------------- 三角形の各頂点のワールド座標代入 -------------//
    float3 wpos[6]; //押し出す前の三角形 + 押し出した後の三角形 = 6頂点
    for (uint i = 0; i < vnum; i++)
    {
        wpos[i] = mul(world, float4(input[i].pos, 1)).xyz;
    }
    
    //------------- 三角形の頂点を法線方向に押し出す -------------//
    //押し出す量
    float extrusion = extrusionTimer[pid % 3] * 0.001f;
    extrusion *= sin(pid) * pid;
    
    //三角形の法線方向取得
    float3 triNormal = input[0].normal + input[1].normal + input[2].normal;
    //その方向に押し出す量を掛けたオフセットを出す
    float3 offset = normalize(mul(world, float4(triNormal, 0))) * extrusion;
    //押し出した座標を取得
    for (uint j = vnum; j < 6; j++)
    {
        wpos[j] = wpos[j - vnum] + offset; //押し出す前の頂点 + オフセット
    }
            
    //------------- 押し出した上面と側面のプリミティブを出力する -------------//   
    if (isAvoid)
    {
        //押し出された上面の三角形
        for (uint k = vnum; k < 6; k++)
        {
            element.svpos = mul(viewproj, float4(wpos[k], 1));
            element.worldpos = float4(wpos[k], 1);
            element.normal = triNormal * saturate(wpos[k].xyz);
            element.uv = input[k - vnum].uv;
            element.scale = scale;
        
            output.Append(element);
        }
        
        //側面
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