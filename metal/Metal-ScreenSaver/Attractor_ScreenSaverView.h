//
//  Attractor_ScreenSaverView.h
//  Metal-ScreenSaver
//
//  Created by Antoine FEUERSTEIN on 2/18/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <MetalKit/MetalKit.h>
#import <Metal/Metal.h>

@interface Attractor_ScreenSaverView : ScreenSaverView <MTKViewDelegate> {
    MTKView*                        metalView;
    id<MTLComputePipelineState>     computeState;
    
    id<MTLLibrary>                  library;
    
    id<MTLCommandQueue>             commandQueue;
    
    float                           time;
    float                           timespeed;
}

@end
