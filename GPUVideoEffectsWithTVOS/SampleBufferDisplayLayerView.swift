//
//  SampleBufferDisplayLayerView.swift
//  GPUVideoEffectsWithTVOS
//
//  Created by Chris Davis on 30/06/2016.
//  Copyright © 2016 nthState Ltd. All rights reserved.
//

// MARK:- Imports

import UIKit
import Foundation
import AVFoundation

// MARK:- Class

/**
 Displays the contents of a pixel buffer
 
 Note: AVSampleBufferDisplayLayer is currently prohibited in tvOS,
 modify your Xcode so that you remove this restriction.
 */
class SampleBufferDisplayLayerView : UIView {
    
    // MARK:- Properties
    
    /// Video format description
    var videoInfo:CMVideoFormatDescription?
    
    /**
    Force the layer to return a AVSampleBufferDisplayLayer
     */
    #if !(arch(i386) || arch(x86_64)) && os(tvOS)
    override class var layerClass:AnyClass {
        return AVSampleBufferDisplayLayer.self
    }
    #endif
    
    /**
    Convenience property to access the layer cast as AVSampleBufferDisplayLayer
    */
    #if !(arch(i386) || arch(x86_64)) && os(tvOS)
    private var videoLayer: AVSampleBufferDisplayLayer {
        return layer as! AVSampleBufferDisplayLayer
    }
    #endif
    
    /**
    Enque the pixel buffer
     */
    func displayPixelBuffer(pixelBuffer: CVPixelBuffer, atTime outputTime: CMTime) {
        var err: OSStatus = noErr
        
        if videoInfo == nil || false == CMVideoFormatDescriptionMatchesImageBuffer(videoInfo!, pixelBuffer) {
            if videoInfo != nil {
                videoInfo = nil
            }
            err = CMVideoFormatDescriptionCreateForImageBuffer(nil, pixelBuffer, &videoInfo)
            if (err != noErr) {
                print("Error at CMVideoFormatDescriptionCreateForImageBuffer \(err)")
            }
        }
        
        var sampleTimingInfo = CMSampleTimingInfo(duration: kCMTimeInvalid, presentationTimeStamp: outputTime, decodeTimeStamp: kCMTimeInvalid)
        var sampleBuffer: CMSampleBuffer?
        err = CMSampleBufferCreateForImageBuffer(nil, pixelBuffer, true, nil, nil, videoInfo!, &sampleTimingInfo, &sampleBuffer)
        if (err != noErr) {
            print("Error at CMSampleBufferCreateForImageBuffer \(err)")
        }
        
        #if !(arch(i386) || arch(x86_64)) && os(tvOS)
        if videoLayer.isReadyForMoreMediaData {
            videoLayer.enqueue(sampleBuffer!)
        }
        #endif
    }
    
    /**
    Clear all enqueued frames, useful for when restarting a video
    */
    func flush() {
        #if !(arch(i386) || arch(x86_64)) && os(tvOS)
        videoLayer.flush()
        #endif
    }
    
}
