//
//  MetalEngine_MPS.swift
//  GPUVideoEffectsWithTVOS
//
//  Created by Chris Davis on 30/06/2016.
//  Copyright © 2016 nthState Ltd. All rights reserved.
//

// MARK:- Imports

import Foundation
import Metal
#if !(arch(i386) || arch(x86_64)) && os(tvOS)
    import MetalKit
    import MetalPerformanceShaders
#endif

// MARK:- Class

/**
 Runs a texture, backed by a pixel buffer through a MPS Shader
 */
class MetalEngine_MPS : MetalEngineProtocol
{
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
    
    #if !(arch(i386) || arch(x86_64)) && os(tvOS)
    var blur: MPSImageGaussianBlur!
    #endif
    
    init()
    {
        device = MTLCreateSystemDefaultDevice()
        defaultLibrary = device!.newDefaultLibrary()!
        commandQueue = device!.makeCommandQueue()
        
        kernelFunction = defaultLibrary.makeFunction(name: "PassThrough")
        
        do
        {
            pipelineState = try device!.makeComputePipelineState(function: kernelFunction!)
        }
        catch
        {
            fatalError("Unable to create pipeline state")
        }

        threadsPerThreadgroup = MTLSizeMake(16, 16, 1)
        let widthInThreadgroups = (1920 + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width
        let heightInThreadgroups = (1080 + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height
        threadgroupsPerGrid = MTLSizeMake(widthInThreadgroups, heightInThreadgroups, 1)
        
        setBlurSigma(sigma: 20)
    }
    
    func setBlurSigma(sigma: Float)
    {
        #if !(arch(i386) || arch(x86_64)) && os(tvOS)
        blur = MPSImageGaussianBlur(device: device!, sigma: sigma)
        #endif
    }
    
    func apply(newTex:inout MTLTexture?)
    {
        #if !(arch(i386) || arch(x86_64)) && os(tvOS)
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.endEncoding()
        blur.encode(commandBuffer: commandBuffer, inPlaceTexture: &newTex!, fallbackCopyAllocator: nil)
        commandBuffer.commit();
        commandBuffer.waitUntilCompleted()
        #endif
    }
    
}
