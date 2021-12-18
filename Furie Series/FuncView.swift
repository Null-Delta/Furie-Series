//
//  FuncView.swift
//  Furie Series
//
//  Created by Rustam Khakhuk on 18.12.2021.
//

import AppKit

class FuncView: NSView {
    private var values: [CGPoint] = [.zero]
    private var furieValues: [CGPoint] = [.zero]

    private var lastPoint: CGPoint = .zero
    private var drawFurie: Bool = false

    
    override var bounds: NSRect {
        didSet {
            values = [CGPoint].init(repeating: .zero, count: Int(bounds.width))
            addTrackingArea(NSTrackingArea(rect: bounds, options: .activeAlways, owner: self, userInfo: nil))
        }
    }
    
    override func viewDidMoveToWindow() {
        values = []
        for j in 0..<Int(bounds.width) {
            values.append(CGPoint(x: j, y: 0))
        }

        self.addGestureRecognizer(panGest)
    }
    
    func calculateFurie(of: Int) {
        drawFurie = true
        furieValues = []
        let a0 = integral * 1 / 3.1428
        let delta = 3.1428 / (bounds.width)

        for j in 0..<Int(bounds.width) {
            var sum = 0.0
            sum += a0 / 2.0
            
            for k in 1..<of {
                let a = 1 / 3.1428 * integralSin(n: k)
                let b = 1 / 3.1428 * integralCos(n: k)

                sum += a * sin(CGFloat(j) * delta * CGFloat(k)) + b * cos(CGFloat(j) * delta * CGFloat(k))
            }
            
            furieValues.append(CGPoint(x: CGFloat(j), y: sum))
        }
        
        setNeedsDisplay(bounds)
    }
    
    var integral: CGFloat {
        get {
            var sum: CGFloat = 0
            let delta = 3.1428 * 2 / (bounds.width)
            
            for j in 0..<values.count {
                sum += values[j].y * delta
            }
            
            return sum
        }
    }
    
    func integralSin(n: Int) -> CGFloat {
        var sum: CGFloat = 0
        let delta = 3.1428 / (bounds.width)
        
        for j in 0..<values.count {
            sum += values[j].y * delta * sin(CGFloat(j) * delta * CGFloat(n))
        }
        
        return sum
    }
    
    func integralCos(n: Int) -> CGFloat {
        var sum: CGFloat = 0
        let delta = 3.1428 / (bounds.width)
        
        for j in 0..<values.count {
            sum += values[j].y * delta * cos(CGFloat(j) * delta * CGFloat(n))
        }
        
        return sum
    }
    
    lazy private var panGest : NSPanGestureRecognizer = {
        let gest = NSPanGestureRecognizer(target: self, action: #selector(gesture))
        
        return gest
    }()
    
    @objc private func gesture() {
        if !bounds.contains(panGest.location(in: self)) {
            return
        }
        
        switch panGest.state {
        case .began:
            drawFurie = false
            lastPoint = CGPoint(x: panGest.location(in: self).x, y: panGest.location(in: self).y - bounds.height / 2)

        case .changed:
            values[Int(panGest.location(in: self).x)] = CGPoint(x: panGest.location(in: self).x, y: panGest.location(in: self).y)
            let deltaY = lastPoint.y - panGest.location(in: self).y
            let deltaX = lastPoint.x - panGest.location(in: self).x
            
            for j in Int(min(lastPoint.x, panGest.location(in: self).x))..<Int(max(lastPoint.x, panGest.location(in: self).x)) {
                values[j].y = lastPoint.y + (deltaY / deltaX) * CGFloat(j - Int(min(lastPoint.x, panGest.location(in: self).x)))
            }
            
            lastPoint = panGest.location(in: self)
        default:
            break
        }
        setNeedsDisplay(bounds)
        displayIfNeeded()
    }
    
    var offset: CGFloat {
        get {
            var delta = 0.0
            for j in 0..<values.count {
                delta += values[j].y - furieValues[j].y
            }
            delta /= CGFloat(values.count)
            return delta
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let context = NSGraphicsContext.current!.cgContext
        context.setFillColor(NSColor.black.cgColor)
        context.addRect(bounds)
        context.fillPath()

        context.setStrokeColor(NSColor.white.cgColor)
        
        context.move(to: values.first!)
        context.addLines(between: values)

        context.strokePath()
        
        
        if drawFurie {
            var max = 0.0
            values.forEach({p in
                max = (p.y > max) ? p.y : max
            })
            print(values)
            print("a")
            print(max)
            context.translateBy(x: 0, y:  +offset)
            context.setStrokeColor(NSColor.red.cgColor)
            context.move(to: furieValues.first!)
            context.addLines(between: furieValues)
            context.strokePath()
            context.translateBy(x: 0, y: -offset)
        }
    }
}
