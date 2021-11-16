//
//  ViewController.swift
//  de Jong Attractor Screen Saver
//
//  Created by Francis Chua on 11/15/21.
//

import Foundation

import Metal

import ScreenSaver
import MetalKit


class MainView: ScreenSaverView {
    
    var metalView: MTKView!
    var computeState: MTLComputePipelineState!
    var library: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var time: Float = 0.0
    var timespeed: Float = 0.0
    var a = 0.0,  b = 0.0, c = 0.0,  d = 0.0

    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1/30.0
        self.metalView = MTKView(frame: self.bounds, device: MTLCreateSystemDefaultDevice())
        // self.metalView.delegate = self;
        self.addSubview(self.metalView)
        try! self.library = self.metalView.device!.makeDefaultLibrary(bundle: Bundle.main)
        let compute = self.library.makeFunction(name: "compute_function")
        self.computeState = try! self.metalView.device!.makeComputePipelineState(function: compute!)
        self.commandQueue =  self.metalView.device?.makeCommandQueue()
        self.time = fmod(Float(CFAbsoluteTimeGetCurrent()), 86400.0)
        self.timespeed = Float.pi / 360.0 / 2.0

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: NSRect) {
//    func draw(in view: MTKView) {
//        super.draw(rect)
        
        // Drawing code here.
        NSColor.black.setFill()
        bounds.fill()
        NSColor.white.set()
        
        let hello: String = "Hello world!"
        
        hello.draw(at: NSPoint(x: 100.0, y: 100.0), withAttributes: nil)
    }
    
}

//
//class Attractor_ScreenSaverView: ScreenSaverView {
//    // let vertexData:[Float] =
//    //   [0.0, 1.0, 0.0,
//    //    -1.0, -1.0, 0.0,
//    //    1.0, -1.0, 0.0]
//
//    // var device: MTLDevice!
//    // var metalLayer: CAMetalLayer!
//    // var vertexBuffer: MTLBuffer!
//    // var pipelineState: MTLRenderPipelineState!
//    // var commandQueue: MTLCommandQueue!
//    // var timer: CADisplayLink!
//
//    var metalView: MTKView
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        device = MTLCreateSystemDefaultDevice()
//
//        metalLayer = CAMetalLayer()          // 1
//        metalLayer.device = device           // 2
//        metalLayer.pixelFormat = .bgra8Unorm // 3
//        metalLayer.framebufferOnly = true    // 4
//        metalLayer.frame = view.layer.frame  // 5
//        view.layer.addSublayer(metalLayer)   // 6
//
//        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) // 1
//        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: []) // 2
//
//        // 1
//        let defaultLibrary = device.makeDefaultLibrary()!
//        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
//        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
//
//        // 2
//        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
//        pipelineStateDescriptor.vertexFunction = vertexProgram
//        pipelineStateDescriptor.fragmentFunction = fragmentProgram
//        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//
//        // 3
//        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
//
//        commandQueue = device.makeCommandQueue()
//
//        timer = CADisplayLink(target: self, selector: #selector(gameloop))
//        timer.add(to: RunLoop.main, forMode: .default)
//    }
//
//    func render() {
//        guard let drawable = metalLayer?.nextDrawable() else { return }
//        let renderPassDescriptor = MTLRenderPassDescriptor()
//        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
//        renderPassDescriptor.colorAttachments[0].loadAction = .clear
//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 55.0/255.0, alpha: 1.0)
//
//        let commandBuffer = commandQueue.makeCommandBuffer()!
//        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
//        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
//        renderEncoder.endEncoding()
//
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//
//    @objc func gameloop() {
//        autoreleasepool {
//            self.render()
//        }
//    }
//}
