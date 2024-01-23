#include "GPUParticle.hlsli"

VSOutput main(VSInput input)
{
    VSOutput output; // ピクセルシェーダーに渡す値
    output.pos = input.pos;
    output.uv = input.uv;
    output.rot = input.rot;
    output.color = input.color;
    output.scale = input.scale;
    return output;
}