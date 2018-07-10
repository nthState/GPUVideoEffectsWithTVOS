//
//  NoiseShader.metal
//  GPUVideoEffectsWithTVOS
//
//  Created by Chris Davis on 07/09/2016.
//  Copyright © 2016 nthState Ltd. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

/**
 Adds noise to a input texture
 */
kernel void AddNoise(texture2d<float, access::read> inTexture [[texture(0)]],
                        texture2d<float, access::read> noiseTexture [[texture(1)]],
                        texture2d<float, access::write> outTexture [[texture(2)]],
                        uint2 gid [[thread_position_in_grid]]) {
    float4 inColor = inTexture.read(gid);
    float4 noiseColor = noiseTexture.read(gid);
    float4 combinedColor = inColor + noiseColor;
    outTexture.write(combinedColor, gid);
}
