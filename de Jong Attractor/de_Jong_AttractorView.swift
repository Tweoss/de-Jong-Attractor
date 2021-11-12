//
//  de_Jong_AttractorView.swift
//  de Jong Attractor
//
//  Created by Francis Chua on 11/11/21.
//

import ScreenSaver

struct Point {
    var x: Double
    var y: Double
}

struct RGB {
    var r: Double
    var g: Double
    var b: Double
}

struct ColoredPoint {
    var x: Double
    var y: Double
    var color: RGB
}

let POINT_SIZE = 1

class PongView: ScreenSaverView {
    // private var ballPosition: CGPoint = .zero
    // private var ballVelocity: CGVector = .zero
    // private var paddlePosition: CGFloat = 0
    // private let ballRadius: CGFloat = 15
    // private let paddleBottomOffset: CGFloat = 100
    // private let paddleSize = NSSize(width: 60, height: 20)
    private var colored_points: [ColoredPoint] = []
    private var a: Double = 0.0
    private var b: Double = -2.0
    private var c: Double = -1.2
    private var d: Double = 2.0
    

    // MARK: - Initialization

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
//        ballPosition = CGPoint(x: frame.width / 2, y: frame.height / 2)
//        ballVelocity = initialVelocity()
        colored_points = makePoints(Int(round(pow(2, 13))))
    }

    // private func initialVelocity() -> CGVector {
    //     let desiredVelocityMagnitude: CGFloat = 10
    //     let xVelocity = CGFloat.random(in: 2.5 ... 7.5)
    //     let xSign: CGFloat = Bool.random() ? 1 : -1
    //     let yVelocity = sqrt(pow(desiredVelocityMagnitude, 2) - pow(xVelocity, 2))
    //     let ySign: CGFloat = Bool.random() ? 1 : -1
    //     return CGVector(dx: xVelocity * xSign, dy: yVelocity * ySign)
    // }

    // private func ballIsOOB() -> (xAxis: Bool, yAxis: Bool) {
    //     let xAxisOOB = ballPosition.x - ballRadius <= 0 ||
    //         ballPosition.x + ballRadius >= bounds.width
    //     let yAxisOOB = ballPosition.y - ballRadius <= 0 ||
    //         ballPosition.y + ballRadius >= bounds.height
    //     return (xAxisOOB, yAxisOOB)
    // }

    // private func ballHitPaddle() -> Bool {
    //     let xBounds = (lower: paddlePosition - paddleSize.width / 2,
    //                    upper: paddlePosition + paddleSize.width / 2)
    //     let yBounds = (lower: paddleBottomOffset - paddleSize.height / 2,
    //                    upper: paddleBottomOffset + paddleSize.height / 2)
    //     return ballPosition.x >= xBounds.lower &&
    //         ballPosition.x <= xBounds.upper &&
    //         ballPosition.y - ballRadius >= yBounds.lower &&
    //         ballPosition.y - ballRadius <= yBounds.upper
    // }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func draw(_: NSRect) {
        for point in colored_points {
            drawPoint(point)
        }
        // drawBackground(.white)
        // drawBall()
        // drawPaddle()
        
    }

    // private func drawBackground(_ color: NSColor) {
    //     let background = NSBezierPath(rect: bounds)
    //     color.setFill()
    //     background.fill()
    // }

    // private func drawBall() {
    //     let ballRect = NSRect(x: ballPosition.x - ballRadius,
    //                           y: ballPosition.y - ballRadius,
    //                           width: ballRadius * 2,
    //                           height: ballRadius * 2)
    //     let ball = NSBezierPath(roundedRect: ballRect,
    //                             xRadius: ballRadius,
    //                             yRadius: ballRadius)
    //     NSColor.black.setFill()
    //     ball.fill()
    // }

     private func drawPoint(_ point: ColoredPoint) {
         let pointRect = NSPoint(x: point.x / 3 * bounds.width + bounds.width / 2,
                                 y: point.y / 3 * bounds.height + bounds.height / 2)
         let path = NSBezierPath(ovalIn: NSRect(origin: pointRect,
                                                 size: CGSize(width: POINT_SIZE,
                                                              height: POINT_SIZE)))
         NSColor(red: point.color.r, green: point.color.g, blue: point.color.b, alpha: 1.0).setFill()
         path.fill()
     }

    private func transformPoint(_ point: ColoredPoint, _ a: Double, _ b: Double, _ c: Double, _ d: Double) -> ColoredPoint {
        var x1 = point.x
        var y1 = point.y
        var x2 = x1
        var y2 = y1
        for _ in 0 ... 10 {
            x1 = x2; y1 = y2
            x2 = sin(a * y1) - cos(b * x1)
            y2 = sin(c * x1) - cos(d * y1)
        }
        let v_t = atan(point.y / point.x) / Double.pi
        let rgb = rainbow(v_t / 4.0 + 0.25)
        return ColoredPoint(x: x2 / 2.0, y: y2 / 2.0, color: rgb)
    }

    private func cubehelix(_ x: Double, _ y: Double, _ z: Double) -> RGB {
        let a = y * z * (1.0 - z)
        let c = cos(x + Double.pi / 2.0)
        let s = sin(x + Double.pi / 2.0)
        return RGB(
            r: z + a * (1.78277 * s - 0.14861 * c),
            g: z - a * (0.29227 * c + 0.90649 * s),
            b: z + a * (1.97294 * c)
        )
    }

    private func rainbow(_ t: Double) -> RGB {
        var t = t
        if t < 0.0 || t > 1.0 {
            t -= floor(t)
        }
        let ts = abs(t - 0.5)
        return cubehelix(
            (360.0 * t - 100.0) / 180.0 * Double.pi,
            1.5 - 1.5 * ts,
            0.8 - 0.9 * ts
        )
    }

    func makePoints(_ n: Int) -> [ColoredPoint] {
        return (0 ..< n).map { _ in
            let x: Double = .random(in: -1.0...1.0);
            let y: Double = .random(in: -1.0...1.0);
            let color = RGB( r: 0.0, g: 0.0, b: 0.0)
            return ColoredPoint(x: x, y: y, color: color)
        }
    }

    // private func drawPaddle() {
    //     let paddleRect = NSRect(x: paddlePosition - paddleSize.width / 2,
    //                             y: paddleBottomOffset - paddleSize.height / 2,
    //                             width: paddleSize.width,
    //                             height: paddleSize.height)
    //     let paddle = NSBezierPath(rect: paddleRect)
    //     NSColor.black.setFill()
    //     paddle.fill()
    // }

    override func animateOneFrame() {
        super.animateOneFrame()
        
        colored_points = colored_points.map {
            p in
            return transformPoint(p, a, b, c, d)
        }
        a = -2.0 + sin( Date().timeIntervalSince1970 / 5000)

        // let oobAxes = ballIsOOB()
        // if oobAxes.xAxis {
        //     ballVelocity.dx *= -1
        // }
        // if oobAxes.yAxis {
        //     ballVelocity.dy *= -1
        // }

        // let paddleContact = ballHitPaddle()
        // if paddleContact {
        //     ballVelocity.dy *= -1
        // }

        // ballPosition.x += ballVelocity.dx
        // ballPosition.y += ballVelocity.dy
        // paddlePosition = ballPosition.x

        setNeedsDisplay(bounds)
    }
}
