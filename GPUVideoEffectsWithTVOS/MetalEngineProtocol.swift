//
//  MetalEngineProtocol.swift
//  GPUVideoEffectsWithTVOS
//
//  Created by Chris Davis on 09/09/2016.
//  Copyright © 2016 nthState Ltd. All rights reserved.
//

// MARK:- Imports

import Foundation
import Metal
#if !(arch(i386) || arch(x86_64)) && os(tvOS)
    import MetalKit
    import MetalPerformanceShaders
#endif

// MARK:- Protocol

/**
 We have multiple metal implementations which do different things
 for the demo, so we simply have a protocol to easily switch
 between implementations
 */
protocol MetalEngineProtocol
{
    /**
     Take a MTLTexture and process it
    */
    func apply( newTex:inout MTLTexture?)
}
