//
//  MetalEngine_ImageBlend.swift
//  GPUVideoEffectsWithTVOS
//
//  Created by Chris Davis on 30/06/2016.
//  Copyright © 2016 nthState Ltd. All rights reserved.
//

// MARK:- Imports

import Foundation
import UIKit
import Metal
#if !(arch(i386) || arch(x86_64)) && os(tvOS)
    import MetalKit
    import MetalPerformanceShaders
#endif

// MARK:- Class

/**
 Runs a texture, backed by a pixel buffer through a MPS Shader
 */
class MetalEngine_ImageBlend : MetalEngineProtocol {
    // MARK:- Properties
    
    /// Metal function we are using
    var kernelFunction:MTLFunction?
    /// Metal device, the GPU
    var device: MTLDevice!
    /// Pipeline
    var pipelineState: MTLComputePipelineState!
    /// Library
    var defaultLibrary: MTLLibrary!
    /// Command queue
    var commandQueue: MTLCommandQueue!
    /// Threading
    var threadsPerThreadgroup:MTLSize!
    /// Thread Groups
    var threadgroupsPerGrid: MTLSize!
    /// Noise texture
    var noiseTexture: MTLTexture?
    
    init() {
        device = MTLCreateSystemDefaultDevice()
        defaultLibrary = device!.newDefaultLibrary()!
        commandQueue = device!.makeCommandQueue()
        
        kernelFunction = defaultLibrary.makeFunction(name: "AddNoise")
        
        do {
            pipelineState = try device!.makeComputePipelineState(function: kernelFunction!)
        }
        catch {
            fatalError("Unable to create pipeline state")
        }
        
        loadNoiseTexture()
        
        threadsPerThreadgroup = MTLSizeMake(16, 16, 1)
        let widthInThreadgroups = (1920 + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width
        let heightInThreadgroups = (1080 + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height
        threadgroupsPerGrid = MTLSizeMake(widthInThreadgroups, heightInThreadgroups, 1)
    }

    /**
    Load Noise texture, so we can blend it later
    */
    func loadNoiseTexture() {
        let a = UIImage(named: "noise")!
        noiseTexture = a.textureFromImage(device: device)
    }
    
    func apply( newTex:inout MTLTexture?) {
        #if !(arch(i386) || arch(x86_64)) && os(tvOS)
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setTexture(newTex, at: 0)
        commandEncoder.setTexture(noiseTexture, at: 1)
        commandEncoder.setTexture(newTex, at: 2)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.endEncoding()
        commandBuffer.commit();
        commandBuffer.waitUntilCompleted()
        #endif
    }
}
