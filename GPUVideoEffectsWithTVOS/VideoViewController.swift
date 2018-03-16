//
//  VideoViewController.swift
//  GPUVideoEffectsWithTVOS
//
//  Created by Chris Davis on 30/06/2016.
//  Copyright © 2016 nthState Ltd. All rights reserved.
//

// MARK:- Imports

import UIKit
import AVFoundation
import Metal
#if !(arch(i386) || arch(x86_64)) && os(tvOS)
    import MetalKit
    import MetalPerformanceShaders
#endif

// MARK:- Class

/**
 Handles the rendering of a video through Metal Performance Shaders
 */
class VideoViewController: UIViewController, AVPlayerItemOutputPullDelegate
{

    // MARK:- Properties
    
    /// context for status
    private var myContextStatus = 0
    /// Display link to get correct frame at right time
    var displayLink:CADisplayLink!
    /// Queue for display link
    let videoQueue = DispatchQueue(label: "com.nthState.videoQueue")
    /// Metal Engine, demo1, demo2 or demo3
    var metalEngine:MetalEngineProtocol!
    // Realtime blur
    var device:MTLDevice!
    #if !(arch(i386) || arch(x86_64)) && os(tvOS)
    /// Texture cache
    var videoTextureCache:CVMetalTextureCache?
    #endif
    /// Video output
    var videoOutput:AVPlayerItemVideoOutput!
    /// Sample Buffer, where we show the video frames
    @IBOutlet weak var sampleBufferDisplayLayerView:SampleBufferDisplayLayerView!
    /// Video player
    var player:AVPlayer!
    /// Video player item (asset)
    var playerItem:AVPlayerItem!
    /// Video player layer (render)
    var playerLayer:AVPlayerLayer!
    /// Change this value to the demo you wish to run
    let demo = 5
    /// Change this video to any video url you wish.
    let videoStr = "http://content.jwplatform.com/manifests/vM7nH0Kl.m3u8"

    // MARK:- Standard View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Which demo do you want to run?
        switch demo
        {
        case 1: // Demo 1
            metalEngine = MetalEngine_MPS() // great
        case 2: // Demo 2
            metalEngine = MetalEngine_Gaussian() // poor
        case 3: // Demo 3
            metalEngine = MetalEngine_ImageBlend() // great
        case 4: // Demo 4
            metalEngine = MetalEngine_ColorBlindnessSimulator() // great
        case 5: // Demo 5
            metalEngine = MetalEngine_Animated() // great
        default:
            fatalError("Pick a demo to run")
        }
        
        setupMetal()
        loadVideo()
    }
    
    // MARK:- Metal Setup

    /**
     Configure a metal device so we can create a texture cache
    */
    func setupMetal()
    {
        guard let device = MTLCreateSystemDefaultDevice() else
        {
            return
        }
        
        self.device = device
        
        #if !(arch(i386) || arch(x86_64)) && os(tvOS)
        // Video Cache Texture
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &videoTextureCache)
        #endif
    }
    
    // MARK:- Video configuration
    
    /**
     Load the video
    */
    func loadVideo()
    {
        self.displayLink = CADisplayLink(target: self, selector: #selector(VideoViewController.displayLinkDidFire(displayLink:)))
        if #available(tvOS 10.0, *) {
            self.displayLink?.preferredFramesPerSecond = 60
        } else {
            // Fallback on earlier versions
            // self.displayLink?.frameInterval = 1 - Apple bug, can no-longer set.
        }
        self.displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        self.displayLink?.isPaused = true
        
        // Create an AVURLAsset with an NSURL containing the path to the video
        let videoUrl = URL(string: videoStr)!
        let avasset:AVURLAsset = AVURLAsset(url: videoUrl, options: nil)
        
        // Create an AVPlayerItem using the asset
        playerItem = AVPlayerItem(asset: avasset)
    
        // Create the AVPlayer using the playeritem
        player = AVPlayer(playerItem: playerItem)
        
        // Realtime blur, renders through a MPS shader, then a custom layer
        var settings:[String : AnyObject] = [String : AnyObject]()
        settings[kCVPixelBufferPixelFormatTypeKey as String] = NSNumber(value: kCVPixelFormatType_32BGRA)
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: settings)
        videoOutput.setDelegate(self, queue: videoQueue)
        
        // Start video
        playerItem.add(videoOutput)
        player.play()
        displayLink?.isPaused = false
    }
    
    // MARK:- Display link
    
    /**
     Takes the current frame of the video as a pixel buffer.
     Creates a Metal Texture backed by this buffer.
     Texture is then ran though one of the demo's metal function
     Buffers data is changed
     Buffer is rendered to a AVSampleBufferDisplayLayer
     */
    func displayLinkDidFire(displayLink:CADisplayLink)
    {
        var outputItemTime:CMTime = kCMTimeInvalid
        
        // Calculate the nextVsync time which is when the screen will be refreshed next.
        let nextVSync:CFTimeInterval = (displayLink.timestamp + displayLink.duration)
        
        outputItemTime = self.videoOutput.itemTime(forHostTime: nextVSync)
        
        if self.videoOutput.hasNewPixelBuffer(forItemTime: outputItemTime)
        {
            if let pixelBuffer = self.videoOutput.copyPixelBuffer(forItemTime: outputItemTime, itemTimeForDisplay: nil)
            {
                #if !(arch(i386) || arch(x86_64)) && os(tvOS)
                var tex:CVMetalTexture?
                let w = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
                let h = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
                
                CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                          videoTextureCache!,
                                                          pixelBuffer,
                                                          nil,
                                                          MTLPixelFormat.bgra8Unorm,
                                                          w, h, 0,
                                                          &tex)
                
                var yTexture:MTLTexture? = CVMetalTextureGetTexture(tex!)
                
                // Run Texture through engine
                self.metalEngine.apply(newTex: &yTexture)
                #endif
                
                // Enqueue texture to buffer for display
                self.sampleBufferDisplayLayerView.displayPixelBuffer(pixelBuffer: pixelBuffer, atTime: outputItemTime)
            }
        }
    }

}
