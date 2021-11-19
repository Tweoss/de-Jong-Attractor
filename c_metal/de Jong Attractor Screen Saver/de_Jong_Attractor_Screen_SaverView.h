//
//  de_Jong_Attractor_Screen_SaverView.h
//  de Jong Attractor Screen Saver
//
//  Created by Francis Chua on 11/12/21.
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
    float                           a;
    float                           b;
    float                           c;
    float                           d;
    float                           timespeed;
}

@end
