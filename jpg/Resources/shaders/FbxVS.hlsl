#include "Fbx.hlsli"

SkinOutput ComputeSkin(VSInputPNUBone vsInput)
{
    SkinOutput output = (SkinOutput) 0;
    
    uint iBone; // 計算するボーン番号
    float weight; // ボーンウェイト（重み）
    matrix skinMat; // スキニング行列
    
    // ボーン0
    iBone = vsInput.boneIndices.x;
    weight = vsInput.boneWeights.x;
    skinMat = skinningMat[iBone];
    output.pos += weight * mul(skinMat, vsInput.pos);
    output.normal += weight * mul((float3x3) skinMat, vsInput.normal);
    
    // ボーン1
    iBone = vsInput.boneIndices.y;
    weight = vsInput.boneWeights.y;
    skinMat = skinningMat[iBone];
    output.pos += weight * mul(skinMat, vsInput.pos);
    output.normal += weight * mul((float3x3) skinMat, vsInput.normal);
    
    // ボーン2
    iBone = vsInput.boneIndices.z;
    weight = vsInput.boneWeights.z;
    skinMat = skinningMat[iBone];
    output.pos += weight * mul(skinMat, vsInput.pos);
    output.normal += weight * mul((float3x3) skinMat, vsInput.normal);
    
    // ボーン3
    iBone = vsInput.boneIndices.w;
    weight = vsInput.boneWeights.w;
    skinMat = skinningMat[iBone];
    output.pos += weight * mul(skinMat, vsInput.pos);
    output.normal += weight * mul((float3x3) skinMat, vsInput.normal);
    
    return output;
}

VSOutput main(VSInputPNUBone vsInput)
{
    // スキニング計算
    SkinOutput skinned = ComputeSkin(vsInput);
    
    // 法線にワールド行列によるスケーリング・回転を適用		
    float4 wnormal = normalize(mul(world, float4(skinned.normal, 0)));
    float4 wpos = mul(world, skinned.pos);
    float4 vertexPos = mul(mul(viewproj, world), skinned.pos);

    // ピクセルシェーダーに渡す値
    VSOutput output = (VSOutput) 0;
    output.svpos = vertexPos;
    output.worldpos = wpos;
    output.normal = wnormal.xyz;
    output.uv = vsInput.uv;
	
    return output;
}