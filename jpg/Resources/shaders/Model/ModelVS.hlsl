#include "Model.hlsli"

VSOutput main(float3 pos : POSITION, float3 normal : NORMAL, float2 uv : TEXCOORD)
{
    //法線にワールド行列によるスケーリング・回転を適用
    float4 wnormal = normalize(mul(world, float4(normal, 0)));
    float4 wpos = mul(world, float4(pos, 1));
    
    VSOutput output; // ピクセルシェーダに渡す値
    output.svpos = mul(mul(viewproj, world), float4(pos, 1));
    output.worldpos = wpos;
    output.normal = wnormal.xyz;
    output.uv = uv;
	
    return output;
}