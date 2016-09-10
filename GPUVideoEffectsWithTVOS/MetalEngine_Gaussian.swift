//
//  MetalEngine_Gaussian.swift
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
class MetalEngine_Gaussian : MetalEngineProtocol
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
    /// Generated texture for blur values
    var blurWeightTexture:MTLTexture!
    
    init()
    {
        device = MTLCreateSystemDefaultDevice()
        defaultLibrary = device!.newDefaultLibrary()!
        commandQueue = device!.makeCommandQueue()
        
        kernelFunction = defaultLibrary.makeFunction(name: "gaussian_blur_2d")
        
        do
        {
            pipelineState = try device!.makeComputePipelineState(function: kernelFunction!)
        }
        catch
        {
            fatalError("Unable to create pipeline state")
        }
        
        generateBlurWeightTexture(radius: 15)
        
        threadsPerThreadgroup = MTLSizeMake(16, 16, 1)
        let widthInThreadgroups = (1920 + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width
        let heightInThreadgroups = (1080 + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height
        threadgroupsPerGrid = MTLSizeMake(widthInThreadgroups, heightInThreadgroups, 1)

    }
    
    // FIXME:- This gaussian method seems very slow when used at speed, I'd recommend MPS instead
    func apply( newTex:inout MTLTexture?)
    {
        #if !(arch(i386) || arch(x86_64)) && os(tvOS)
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setTexture(newTex, at: 0)
        commandEncoder.setTexture(self.blurWeightTexture, at: 1)
        commandEncoder.setTexture(newTex, at: 2)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.endEncoding()
        commandBuffer.commit();
        commandBuffer.waitUntilCompleted()
        #endif
    }
    
    /**
     Generate a blur texture
    */
    func generateBlurWeightTexture(radius:Float)
    {
        let sigma:Float = radius / 2.0
        let size:Int = Int(roundf(radius * 2) + 1)
        
        var delta:Float = 0
        var expScale:Float = 0
        if radius > 0
        {
            delta = (radius * 2) / (Float(size) - 1)
            expScale = -1 / (2 * sigma * sigma)
        }
        
        let mallocsize = MemoryLayout<Float>.size * size * size
        let weights = UnsafeMutablePointer<Float>.allocate(capacity: mallocsize)
        
        var weightSum:Float = 0;
        var y:Float = -radius;
        for j in 0 ..< (size + 1)
        {
            y += delta
            var x:Float = -radius;
            for i in 0 ..< (size + 1)
            {
                x += delta
                let weight:Float = expf((x * x + y * y) * expScale);
                weights[j * size + i] = weight;
                weightSum += weight;
            }
        }
        
        let weightScale:Float = 1 / weightSum;
        for j in 0 ..< (size + 1)
        {
            for i in 0 ..< (size + 1)
            {
                weights[j * size + i] *= weightScale;
            }
        }

        let textureDescriptor:MTLTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Float, width: size, height: size, mipmapped: false)
        self.blurWeightTexture = self.device.makeTexture(descriptor: textureDescriptor)
        
        let region:MTLRegion = MTLRegionMake2D(0, 0, size, size)
        self.blurWeightTexture.replace(region: region, mipmapLevel: 0, withBytes: weights, bytesPerRow: MemoryLayout<Float>.size * size)

        weights.deallocate(capacity: mallocsize)
    }

}
