# GPU Video Effects With TVOS

## TL;DR
Shows you how to run realtime effects over a streaming video file on the GPU on Apple tvOS.

### The What

This tutorial will show you how to run realtime effects on a video that is being streamed from the internet at 60 frames per second. 

We are not going to use any 3rd party libraries for this. This is all native.

### The Why

On a project I was asked to blur a video that was playing on the screen (1920 x 1080). I first thought ok, I’ll just use a UIVisualEffect view, this did the trick, but the designer wasn’t happy with it, he wanted more control. So I went and found a load of ways that didn’t work, and one that works amazingly well.

### Demos

There are 5 demos in this projects

- Realtime Blur with MPS (Metal Performance Shaders)
- Realtime Blur with A Custom Gaussian Function (This is slow)
- Realtime Image Blending of a video frame and an image
- Realtime color blindness simulation
- - This is really great if you have a UI over the video and want to see how it looks to people with different color blindnesses
- Realtime animated MPS Blur

### The How

The basic structure of this setup is as follows:
- Metal Performance Shader
- AVPlayer
- AVSampleBufferDisplayLayer (Yes, we can get it to work)
- CADisplayLink

We setup the AVPlayer as you would normally, with the exception we are not going to add an AVPlayerLayer, we use an AVSampleBufferDisplayLayer



### Notes:
- It's written in Swift 3, I've been using Swift 2 for a while now, the upgrade seemed pretty painless.
- The Demo could could be wrapped into helper functions to be shared, but I just wanted it written clearly in each demo.
- There is no buffering code in the demo, I wanted to keep it lean.

#### Caveats:
- You have to modify AVSampleBufferDisplayLayer in Xcode to get it to run. I've included a modified version in this repository.
- You need to run on a device, Metal isn't supported in the simulator
- NSAllowsArbitraryLoads is set to yes in the Demo to load videos from any url

#### Resources:
- Buy Metal By Example by Warren Moore, it's a great book
