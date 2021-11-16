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
        
        return;
    }
    
    
    var metalView: MTKView!
    var computeState: MTLComputePipelineState!
    var library: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var time: Float = fmod(Float(CFAbsoluteTimeGetCurrent()), 86400.0)
    var timespeed: Float = Float.pi / 360.0 / 2.0
    var a: Float = -2.0 + sin(fmod(Float(CFAbsoluteTimeGetCurrent()), 86400.0)), b: Float = -2.0 + sin(fmod(Float(CFAbsoluteTimeGetCurrent()), 86400.0)/120), c: Float = -1.2 + sin(fmod(Float(CFAbsoluteTimeGetCurrent()), 86400.0)/360), d: Float = 2.0 + sin(fmod(Float(CFAbsoluteTimeGetCurrent()), 86400.0)/720)
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1/30.0
        self.metalView = MTKView(frame: frame)
        self.metalView.device = MTLCreateSystemDefaultDevice()
        self.metalView.delegate = self;
        self.addSubview(self.metalView)
        try! self.library = self.metalView.device?.makeDefaultLibrary(bundle: Bundle(for: type(of: self)) )
        let compute = self.library.makeFunction(name: "compute_function")
        self.computeState = try! self.metalView.device!.makeComputePipelineState(function: compute!)
        self.commandQueue =  self.metalView.device?.makeCommandQueue()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override func animateOneFrame() {
        let drawable: CAMetalDrawable = self.metalView.currentDrawable!;
        let buffer: MTLCommandBuffer = self.commandQueue.makeCommandBuffer()!;
        let encoder: MTLComputeCommandEncoder = buffer.makeComputeCommandEncoder()!;
        
        encoder.setComputePipelineState(self.computeState);
        encoder.setTexture(drawable.texture, index: 0);
        encoder.setBytes(&self.time, length: MemoryLayout.size(ofValue: self.time), index: 0);
        encoder.setBytes(&self.a, length: MemoryLayout.size(ofValue: self.a), index: 1);
        encoder.setBytes(&self.b, length: MemoryLayout.size(ofValue: self.b), index: 2);
        encoder.setBytes(&self.c, length: MemoryLayout.size(ofValue: self.c), index: 3);
        encoder.setBytes(&self.d, length: MemoryLayout.size(ofValue: self.d), index: 4);
        let groups: MTLSize = MTLSizeMake(8,8,1);
        let threadPerGroup = MTLSizeMake(drawable.texture.width / groups.width, drawable.texture.height / groups.height, groups.depth);
        encoder.dispatchThreadgroups(threadPerGroup, threadsPerThreadgroup: groups);
        encoder.endEncoding();
        buffer.present(drawable);
        buffer.commit();
        
        self.time += self.timespeed;
        self.a = -2.0 + sin(time);
        self.b = -2.0 + sin(time / 120);
        self.c = -1.2 + sin(time / 360);
        self.d =  2.0 + sin(time / 720);
        
    }
    
    func clearStage() {
    }
    

    override func draw(_ rect: NSRect) {
    }
}
