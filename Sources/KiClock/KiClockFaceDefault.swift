//
//  KIDefaultFace.swift
//
//  Created by Ivailo Kanev on 30/01/21.
//
#if os(iOS)
import UIKit
open class KiClockFaceDefault: KiClockFaceProtocol {
    open var clockBorderColor: UIColor = .black
    open var clockBorderWidth: CGFloat = 1.0
    open var hourClockIndexColor: UIColor = .black
    open var hourClockIndexWidth: CGFloat = 4.0
    open var minuteClockIndexColor: UIColor = .black
    open var minuteClockIndexWidth: CGFloat = 2.0
    open var clockColor: UIColor = .white
    open var clockLabelsFont: UIFont = UIFont.systemFont(ofSize: 20)
    open var timeLabelTextColor: UIColor = .black
    public var bounds: CGRect {
        return parent?.bounds ?? .null
    }
    open var centerCircleLineColor: UIColor = .black
    private var parent: UIView?

    public func draw(bottom view: UIView) {
        parent = view
        let layer = CAShapeLayer()
        layer.frame = bounds
        layer.cornerRadius = radius
        layer.masksToBounds = true
        layer.borderWidth = clockBorderWidth
        layer.borderColor = clockBorderColor.cgColor
        
        let smallClockIndexLayer = { () -> CAShapeLayer in
            let layer = CAShapeLayer()
            layer.frame = bounds
            layer.strokeColor = minuteClockIndexColor.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = minuteClockIndexWidth
            
            let smallRadius = radius - (radius/10 + clockBorderWidth)
            var angle = angle270
            let offesetRadius = radius - 5
            let path = UIBezierPath()
            for i in 0..<60 {
                if i%5 == 0 {
                    angle += Float(Double.pi/30)
                    continue
                }
                let startPoint = CGPoint(x: clockCenter.x + offesetRadius * CGFloat(cosf(angle)), y: clockCenter.y + offesetRadius * CGFloat(sinf(angle)))
                path.move(to: startPoint)
                let endPoint = CGPoint(x: clockCenter.x + smallRadius * CGFloat(cosf(angle)), y: clockCenter.y + smallRadius * CGFloat(sinf(angle)))
                path.addLine(to: endPoint)
                angle += Float(Double.pi/30)
            }
            layer.path = path.cgPath
            return layer
            
        }()
        layer.addSublayer(smallClockIndexLayer)
        let hoursClockIndexLayer = { () -> CAShapeLayer in
            let layer = CAShapeLayer()
            layer.frame = bounds
            layer.strokeColor = hourClockIndexColor.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = hourClockIndexWidth
            
            let smallRadius = radius - (radius/8 + clockBorderWidth)
            var angle = angle270
            let path = UIBezierPath()
            let offesetRadius = radius - 5
            for _ in 0..<12 {
                let startPoint = CGPoint(x: clockCenter.x + offesetRadius * CGFloat(cosf(angle)), y: clockCenter.y + offesetRadius * CGFloat(sinf(angle)))
                path.move(to: startPoint)
                let endPoint = CGPoint(x: clockCenter.x + smallRadius * CGFloat(cosf(angle)), y: clockCenter.y + smallRadius * CGFloat(sinf(angle)))
                path.addLine(to: endPoint)
                angle += angle30
            }
            layer.path = path.cgPath
            return layer
        }()
        
        
        layer.addSublayer(hoursClockIndexLayer)
        
        let clockLayer = { () -> CAShapeLayer in
            let layer = CAShapeLayer()
            let path = UIBezierPath(ovalIn: CGRect(x: clockCenter.x - radius, y: clockCenter.y - radius, width: radius * 2, height: radius * 2))
            layer.frame = bounds
            layer.strokeColor = UIColor.clear.cgColor
            layer.fillColor =  clockColor.cgColor
            layer.path = path.cgPath
            return layer
        }()
        layer.insertSublayer(clockLayer, at: 0)
        
        setupTimeLabel(layer: layer)
        parent?.layer.insertSublayer(layer, at: 0)
    }
    
    public func draw(top view: UIView) {
        parent = view
        let layer = CAShapeLayer ()
        let smallRadius: CGFloat = 8
        let path = UIBezierPath(ovalIn: CGRect(x: clockCenter.x - smallRadius, y: clockCenter.y - smallRadius, width: smallRadius * 2, height: smallRadius * 2))
        layer.frame = bounds
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = centerCircleLineColor.cgColor
        layer.path = path.cgPath
        parent?.layer.addSublayer(layer)
    }
    
    private func setupTimeLabel(layer: CAShapeLayer) {
        var smallRadius = radius - (radius/10 + clockBorderWidth)
        let length = radius/4
        smallRadius -= length/2
        
        for i in 0..<12 {
            let label = { () -> CATextLayer in
                let label = CATextLayer()
                label.string = String(12-i)
                let size = String(12-i).size(withAttributes: [.font: clockLabelsFont])
                label.frame =  CGRect(origin: .zero, size: size)
                label.alignmentMode = .center
                label.fontSize = clockLabelsFont.pointSize
                label.font = clockLabelsFont
                label.foregroundColor = timeLabelTextColor.cgColor
                return label
            }()
            
            
            let angle = angle270 - Float(i) * angle30
            let point = CGPoint(x: clockCenter.x + smallRadius * CGFloat(cosf(angle)), y: clockCenter.y + smallRadius * CGFloat(sinf(angle)))
            label.position = point
            layer.addSublayer(label)
        }
    }
}
#endif
