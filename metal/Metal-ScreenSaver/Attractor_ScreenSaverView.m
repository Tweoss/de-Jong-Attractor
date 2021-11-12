//
//  Attractor_ScreenSaverView.m
//  Metal-ScreenSaver
//
//  Created by Antoine FEUERSTEIN on 2/18/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

#import "Attractor_ScreenSaverView.h"

@implementation Attractor_ScreenSaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
        self->metalView = [[MTKView alloc] initWithFrame:[self frame]];
        self->metalView.device = MTLCreateSystemDefaultDevice();
        self->metalView.delegate = self;
        [self addSubview:self->metalView];
        
        self->library = [self->metalView.device newDefaultLibraryWithBundle:[NSBundle bundleForClass:self.class] error:NULL];
        id<MTLFunction>     compute = [self->library newFunctionWithName:@"compute_function"];
        NSError*       error;
        
        self->computeState = [self->metalView.device newComputePipelineStateWithFunction:compute error:&error];
        
        self->commandQueue = [self->metalView.device newCommandQueue];
        self->time = 0;
        self->timespeed = M_PI / 360;
    }
    return self;
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    id<CAMetalDrawable>            drawable = self->metalView.currentDrawable;
    id<MTLCommandBuffer>           buffer = [self->commandQueue commandBuffer];
    id<MTLComputeCommandEncoder>   encoder = [buffer computeCommandEncoder];
   
    [encoder setComputePipelineState:self->computeState];
    [encoder setTexture:drawable.texture atIndex:0];
    [encoder setBytes:&self->time length:sizeof(float) atIndex:0];
    MTLSize groups = MTLSizeMake(8, 8, 1);
    MTLSize threadPerGroup = MTLSizeMake(drawable.texture.width / groups.width, drawable.texture.height / groups.height, groups.depth);
    
    [encoder dispatchThreadgroups:threadPerGroup threadsPerThreadgroup:groups];
    [encoder endEncoding];
    
    [buffer presentDrawable:drawable];
    [buffer commit];
    
    
    self->time += self->timespeed;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
