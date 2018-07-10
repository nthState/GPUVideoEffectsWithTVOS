//
//  ImageExtensions.swift
//  GPUVideoEffectsWithTVOS
//
//  Created by Chris Davis on 09/09/2016.
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

// MARK:- Extension

extension UIImage {
    /**
     Creates a Metal Texture from a UIImage
     
     - parameter image: UIImage
     - returns: MTLTexture
     */
    func textureFromImage(device:MTLDevice) -> MTLTexture? {
        #if !(arch(i386) || arch(x86_64)) && os(tvOS)
            guard let cgImage = self.cgImage else {
                fatalError("Can't open image \(self)")
            }
            
            let textureLoader = MTKTextureLoader(device: device)
            do {
                let textureOut = try textureLoader.newTexture(with: cgImage, options: nil)
                return textureOut
            }
            catch {
                fatalError("Can't load texture")
            }
        #else
            return nil
        #endif
    }
}
