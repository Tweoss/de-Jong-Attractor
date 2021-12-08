//
//  ScreenSaver.swift
//  swift_metal
//
//  Created by Francis Chua on 11/15/21.
//

import ScreenSaver
import Foundation
import Metal
import MetalKit

class Main: ScreenSaverView, MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        return;
    }
    
    func draw(in view: MTKView) {
        let drawable: CAMetalDrawable = self.metalView.currentDrawable!;
        let buffer: MTLCommandBuffer = self.commandQueue.makeCommandBuffer()!;
        
        let encoder: MTLComputeCommandEncoder = buffer.makeComputeCommandEncoder()!;
        
        encoder.setComputePipelineState(self.transformState);
        encoder.setTexture(drawable.texture, index: 0);
        encoder.setBytes(&self.time, length: MemoryLayout.size(ofValue: self.time), index: 1);
        encoder.setBytes(&self.a, length: MemoryLayout.size(ofValue: self.a), index: 2);
        encoder.setBytes(&self.b, length: MemoryLayout.size(ofValue: self.b), index: 3);
        encoder.setBytes(&self.c, length: MemoryLayout.size(ofValue: self.c), index: 4);
        encoder.setBytes(&self.d, length: MemoryLayout.size(ofValue: self.d), index: 5);
        let groups: MTLSize = MTLSizeMake(8,8,1);
        let threadPerGroup = MTLSizeMake(drawable.texture.width / groups.width, drawable.texture.height / groups.height, groups.depth);
        encoder.dispatchThreadgroups(threadPerGroup, threadsPerThreadgroup: groups);
        encoder.endEncoding();
        
        buffer.present(drawable);
        buffer.commit();

        self.time += self.timespeed;
        self.a = -2.0 + sin(self.time * Float.pi / 200.0);
        self.b = -2.0 + sin(self.time * Float.pi / 200.0 / 20 );
        self.c = -1.2 + sin(self.time * Float.pi / 200.0 / 20 / 10 );
        self.d = -2.0 + sin(self.time * Float.pi / 200.0 / 20 / 10 / 6);
        return;
    }
    
    var metalView: MTKView!
    var transformState: MTLComputePipelineState!
    var library: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var time: Float!
    var timespeed: Float!
    var a: Float!, b: Float!, c: Float!, d: Float!
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.metalView = MTKView(frame: frame)
        self.metalView.device = MTLCreateSystemDefaultDevice()
        self.metalView.delegate = self;
        self.addSubview(self.metalView)
        try! self.library = self.metalView.device?.makeDefaultLibrary(bundle: Bundle(for: type(of: self)) )
        let transform = self.library.makeFunction(name: "transform_function")
        self.transformState = try! self.metalView.device!.makeComputePipelineState(function: transform!)
        self.commandQueue =  self.metalView.device?.makeCommandQueue()

        self.time = fmod(Float(CFAbsoluteTimeGetCurrent()), 86400.0);
        self.timespeed = Float(0.33)
        self.a = sin(self.time * Float.pi / 200.0);
        self.b = -1.0 + sin(self.time * Float.pi / 200.0 / 10 );
        self.c = -1.2 + sin(self.time * Float.pi / 200.0 / 10 / 10 );
        self.d = -2.0 + sin(self.time * Float.pi / 200.0 / 10 / 10 / 6);
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func animateOneFrame() {
    }
    
    func clearStage() {
    }
    
    
    override func draw(_ rect: NSRect) {
    }
}
