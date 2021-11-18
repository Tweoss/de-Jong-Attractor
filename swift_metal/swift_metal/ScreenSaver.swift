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

struct Constants {
    static let POINT_COUNT: Int = Int(powf(2, 14));
}

struct Point {
    var coord: SIMD2<Float>;
};

class Main: ScreenSaverView, MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        return;
    }
    
    func draw(in view: MTKView) {
        let drawable: CAMetalDrawable = self.metalView.currentDrawable!;
        let buffer: MTLCommandBuffer = self.commandQueue.makeCommandBuffer()!;
        
        let encoder_2: MTLComputeCommandEncoder = buffer.makeComputeCommandEncoder()!;
        encoder_2.setComputePipelineState(self.fillState);
        encoder_2.setTexture(drawable.texture, index: 0);
        let fill_groups: MTLSize = MTLSizeMake(8,8,1);
        let fill_threadPerGroup: MTLSize = MTLSizeMake(drawable.texture.width / fill_groups.width, drawable.texture.height / fill_groups.height, fill_groups.depth);
        encoder_2.dispatchThreadgroups(fill_threadPerGroup, threadsPerThreadgroup: fill_groups);
//        encodser_2.endEncoding();
        
//
//        let encoder: MTLComputeCommandEncoder = buffer.makeComputeCommandEncoder()!;
        let dataSize = vertexData.count*MemoryLayout<Point>.stride
        
        self.vertexBuffer = self.metalView.device?.makeBuffer(bytes: vertexData, length: dataSize, options: [])
//        vertexData.withUnsafeBufferPointer { dataPtr in
//            let rawPtr:UnsafeMutableRawPointer = UnsafeMutableRawPointer(mutating: dataPtr.baseAddress!);
        
        encoder_2.setComputePipelineState(self.transformState);
        encoder_2.setTexture(drawable.texture, index: 0);
        encoder_2.setBuffer(vertexBuffer, offset: 0, index: 0);
        encoder_2.setBytes(&self.time, length: MemoryLayout.size(ofValue: self.time), index: 1);
        encoder_2.setBytes(&self.a, length: MemoryLayout.size(ofValue: self.a), index: 2);
        encoder_2.setBytes(&self.b, length: MemoryLayout.size(ofValue: self.b), index: 3);
        encoder_2.setBytes(&self.c, length: MemoryLayout.size(ofValue: self.c), index: 4);
        encoder_2.setBytes(&self.d, length: MemoryLayout.size(ofValue: self.d), index: 5);
        let groups: MTLSize = MTLSizeMake(4,1,1);
        let threadPerGroup = MTLSize(width: vertexBuffer!.length / groups.width, height: 1, depth: 1);
        encoder_2.dispatchThreadgroups(threadPerGroup, threadsPerThreadgroup: groups);
        encoder_2.endEncoding();
       
        
        buffer.present(drawable);
        buffer.commit();

        self.time += self.timespeed;
        self.a = -2.0 + sin(time);
        self.b = -2.0 + sin(time / 120);
        self.c = -1.2 + sin(time / 360);
        self.d =  2.0 + sin(time / 720);
        return;
    }
    
    
    var metalView: MTKView!
    var transformState: MTLComputePipelineState!
    var fillState: MTLComputePipelineState!
    var library: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var time: Float = fmod(Float(CFAbsoluteTimeGetCurrent()), 86400.0)
    var timespeed: Float = Float.pi / 360.0 / 2.0
    var a: Float = -2.0 + sin(fmod(Float(CFAbsoluteTimeGetCurrent()), 86400.0)), b: Float = -2.0 + sin(fmod(Float(CFAbsoluteTimeGetCurrent()), 86400.0)/120), c: Float = -1.2 + sin(fmod(Float(CFAbsoluteTimeGetCurrent()), 86400.0)/360), d: Float = 2.0 + sin(fmod(Float(CFAbsoluteTimeGetCurrent()), 86400.0)/720)
    
    var vertexData: Array<Point>!
    var vertexBuffer: MTLBuffer!
    
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 1/10.0
        self.metalView = MTKView(frame: frame)
        self.metalView.device = MTLCreateSystemDefaultDevice()
        self.metalView.delegate = self;
        self.addSubview(self.metalView)
        try! self.library = self.metalView.device?.makeDefaultLibrary(bundle: Bundle(for: type(of: self)) )
        let fill_black = self.library.makeFunction(name: "fill_black")
        self.fillState = try!
        self.metalView.device!
            .makeComputePipelineState(function: fill_black!);
        let transform = self.library.makeFunction(name: "transform_function")
        self.transformState = try! self.metalView.device!.makeComputePipelineState(function: transform!)
        self.commandQueue =  self.metalView.device?.makeCommandQueue()
        self.vertexData = (0..<Constants.POINT_COUNT).map { _ in Point(coord: SIMD2<Float>(Float.random(in: -1.0...1.0), Float.random(in: -1.0...1.0))) };
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
