//
//  Shader.metal
//  GPUVideoEffectsWithTVOS
//
//  Created by Chris Davis on 30/06/2016.
//  Copyright © 2016 nthState Ltd. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

/**
 Simple pass through kernel
 Writes the input straight to the output texture
 */
kernel void PassThrough(texture2d<float, access::read> inTexture [[texture(0)]],
                        texture2d<float, access::write> outTexture [[texture(1)]],
                        uint2 gid [[thread_position_in_grid]]) {
    outTexture.write(inTexture.read(gid), gid);
}
