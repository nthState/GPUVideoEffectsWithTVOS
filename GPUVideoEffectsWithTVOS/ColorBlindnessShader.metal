//
//  ColorBlindnessShader.metal
//  GPUVideoEffectsWithTVOS
//
//  Created by Chris Davis on 10/09/2016.
//  Copyright © 2016 nthState Ltd. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


kernel void protanope(texture2d<float, access::read> inTexture [[texture(0)]],
                      texture2d<float, access::write> outTexture [[texture(1)]],
                      uint2 gid [[thread_position_in_grid]])
{
    float3x3 protanope = {{ 0.567,0.433,0,},
        { 0.558,0.442,0},
        { 0,0.242,0.758}};
    
    float3 rgb = inTexture.read(gid).rgb;
    float3 color = rgb * protanope;
    float4 combinedColor = float4(color,1.0);
    
    outTexture.write(combinedColor, gid);
}

kernel void deuteranope(texture2d<float, access::read> inTexture [[texture(0)]],
                        texture2d<float, access::write> outTexture [[texture(1)]],
                        uint2 gid [[thread_position_in_grid]])
{
    
    float3x3 deuteranope = {{ 0.625,0.375,0,},
        { 0.7,0.3,0},
        { 0,0.3,0.7}};
    
    float3 rgb = inTexture.read(gid).rgb;
    float3 color = rgb * deuteranope;
    float4 combinedColor = float4(color,1.0);
    
    outTexture.write(combinedColor, gid);
}

kernel void tritanopia(texture2d<float, access::read> inTexture [[texture(0)]],
                       texture2d<float, access::write> outTexture [[texture(1)]],
                       uint2 gid [[thread_position_in_grid]])
{
    
    float3x3 tritanopia = {{ 0.95,0.05,0,},
        { 0,0.433,0.567},
        {  0,0.475,0.525}};
    
    float3 rgb = inTexture.read(gid).rgb;
    float3 color = rgb * tritanopia;
    float4 combinedColor = float4(color,1.0);
    
    outTexture.write(combinedColor, gid);
}

//http://www.color-blindness.com/coblis-color-blindness-simulator/
//http://web.archive.org/web/20081014161121/http://www.colorjack.com/labs/colormatrix/

//{Normal:{ R:[100, 0, 0], G:[0, 100, 0], B:[0, 100, 0]},
//Protanopia:{ R:[56.667, 43.333, 0], G:[55.833, 44.167, 0], B:[0, 24.167, 75.833]},
//Protanomaly:{ R:[81.667, 18.333, 0], G:[33.333, 66.667, 0], B:[0, 12.5, 87.5]},
//Deuteranopia:{ R:[62.5, 37.5, 0], G:[70, 30, 0], B:[0, 30, 70]},
//Deuteranomaly:{ R:[80, 20, 0], G:[25.833, 74.167, 0], B:[0, 14.167, 85.833]},
//Tritanopia:{ R:[95, 5, 0], G:[0, 43.333, 56.667], B:[0, 47.5, 52.5]},
//Tritanomaly:{ R:[96.667, 3.333, 0], G:[0, 73.333, 26.667], B:[0, 18.333, 81.667]},
//Achromatopsia:{ R:[29.9, 58.7, 11.4], G:[29.9, 58.7, 11.4], B:[29.9, 58.7, 11.4]},
//Achromatomaly:{ R:[61.8, 32, 6.2], G:[16.3, 77.5, 6.2], B:[16.3, 32.0, 51.6]}

//({'Normal':[1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Protanopia':[0.567,0.433,0,0,0, 0.558,0.442,0,0,0, 0,0.242,0.758,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Protanomaly':[0.817,0.183,0,0,0, 0.333,0.667,0,0,0, 0,0.125,0.875,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Deuteranopia':[0.625,0.375,0,0,0, 0.7,0.3,0,0,0, 0,0.3,0.7,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Deuteranomaly':[0.8,0.2,0,0,0, 0.258,0.742,0,0,0, 0,0.142,0.858,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Tritanopia':[0.95,0.05,0,0,0, 0,0.433,0.567,0,0, 0,0.475,0.525,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Tritanomaly':[0.967,0.033,0,0,0, 0,0.733,0.267,0,0, 0,0.183,0.817,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Achromatopsia':[0.299,0.587,0.114,0,0, 0.299,0.587,0.114,0,0, 0.299,0.587,0.114,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Achromatomaly':[0.618,0.320,0.062,0,0, 0.163,0.775,0.062,0,0, 0.163,0.320,0.516,0,0,0,0,0,1,0,0,0,0,0]}[v]);

