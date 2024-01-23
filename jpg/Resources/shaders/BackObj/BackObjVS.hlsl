#include "BackObj.hlsli"

VSOutput main(VSInput input)
{
    VSOutput element;
    
    element.pos = input.pos;
    element.normal = input.normal;
    element.uv = input.uv;
    
    return element;
}