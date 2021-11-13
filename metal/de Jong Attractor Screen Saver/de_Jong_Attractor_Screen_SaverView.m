//
//  de_Jong_Attractor_Screen_SaverView.m
//  de Jong Attractor Screen Saver
//
//  Created by Francis Chua on 11/12/21.
//

#import "de_Jong_Attractor_Screen_SaverView.h"

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
        self->time = fmod((float) CFAbsoluteTimeGetCurrent(), 86400);
        self->timespeed = M_PI / 360 / 2;
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
    [encoder setBytes:&self->a length:sizeof(float) atIndex:1];
    [encoder setBytes:&self->b length:sizeof(float) atIndex:2];
    [encoder setBytes:&self->c length:sizeof(float) atIndex:3];
    [encoder setBytes:&self->d length:sizeof(float) atIndex:4];
    MTLSize groups = MTLSizeMake(8, 8, 1);
    MTLSize threadPerGroup = MTLSizeMake(drawable.texture.width / groups.width, drawable.texture.height / groups.height, groups.depth);
    
    [encoder dispatchThreadgroups:threadPerGroup threadsPerThreadgroup:groups];
    [encoder endEncoding];
    
    [buffer presentDrawable:drawable];
    [buffer commit];
    
    
    self->time += self->timespeed;
    self->a = -2.0 + sin(time);
    self->b = -2.0 + sin(time / 120);
    self->c = -1.2 + sin(time / 360);
    self->d =  2.0 + sin(time / 720);
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
