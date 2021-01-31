//
//  KIDefaultFace.swift
//
//  Created by Ivailo Kanev on 30/01/21.
//
#if os(iOS)
import UIKit
open class KiClockFaceFun: KiClockFaceProtocol {
    open var clockBorderColor: UIColor = .black
    open var clockBorderWidth: CGFloat = 1.0
    open var clockMinutesBorderColor: UIColor = UIColor(red: 133/255, green: 214/255, blue: 255/255, alpha: 1)
    open var hourClockIndexColor: UIColor = .white
    open var hourClockIndexWidth: CGFloat = 4.0
    open var minuteClockIndexColor: UIColor = .white
    open var minuteClockIndexWidth: CGFloat = 3.0
    open var clockColor: UIColor = .white
    open var clockLabelsFont: UIFont = UIFont.systemFont(ofSize: 28, weight: .medium)
    open var clockMinuteFont: UIFont = UIFont.systemFont(ofSize: 9, weight: .semibold)
    open var timeLabelTextColor: UIColor = .white
    open var minuteLabelTextColor: UIColor = UIColor(red: 0/255, green: 102/255, blue: 204/255, alpha: 1)
    public var bounds: CGRect {
        return parent?.bounds ?? .null
    }
    open var centerCircleLineColor: UIColor = UIColor(red: 255/255, green: 102/255, blue: 0/255, alpha: 1)
    private var parent: UIView?

    public func draw(bottom view: UIView) {
        parent = view
        let layer = CAShapeLayer()
        layer.frame = bounds
        layer.cornerRadius = radius
        layer.masksToBounds = true
        layer.borderWidth = 0

        let ringMinutesClockLayer = { () -> CAShapeLayer in
            let layer = CAShapeLayer()
            layer.frame = bounds
            layer.strokeColor = UIColor.clear.cgColor
            layer.fillColor = clockMinutesBorderColor.cgColor
            layer.fillRule = .evenOdd
            let margin: CGFloat =  18
            let path = UIBezierPath()
            let cicle = UIBezierPath()
            let point = CGPoint(x: clockCenter.x, y: clockCenter.y)
            cicle.addArc(withCenter: point, radius: radius, startAngle: convert(0), endAngle: convert(360), clockwise: true)
            cicle.close()
            path.append(cicle)
            path.addArc(withCenter: point, radius: radius-margin, startAngle: convert(0), endAngle: convert(360), clockwise: true)
            path.close()
            layer.path = path.cgPath
            return layer
            
        }()
        layer.addSublayer(ringMinutesClockLayer)
        let ringClockLayer = { () -> CAGradientLayer in
            let layer = CAShapeLayer()
            layer.frame = bounds
            layer.strokeColor = UIColor.clear.cgColor
            layer.fillColor = UIColor.orange.cgColor
            layer.fillRule = .evenOdd
            let margin: CGFloat = 18
            let path = UIBezierPath()
            let cicle = UIBezierPath()
            let point = CGPoint(x: clockCenter.x, y: clockCenter.y)
            cicle.addArc(withCenter: point, radius: radius-margin, startAngle: convert(0), endAngle: convert(360), clockwise: true)
            cicle.close()
            path.append(cicle)
            path.addArc(withCenter: point, radius: radius-margin*3.5, startAngle: convert(0), endAngle: convert(360), clockwise: true)
            path.close()
            layer.path = path.cgPath
            let gradientLayer = CAGradientLayer()
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            // make sure to use .cgColor
            gradientLayer.colors = [UIColor(red: 255/255, green: 102/255, blue: 0/255, alpha: 1).cgColor,
                                    UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: 1).cgColor]
            gradientLayer.frame = bounds
            gradientLayer.mask = layer
            return gradientLayer
            
            
        }()
        layer.addSublayer(ringClockLayer)
        let smallClockIndexLayer = { () -> CAShapeLayer in
            let layer = CAShapeLayer()
            layer.frame = bounds
            layer.strokeColor = UIColor.clear.cgColor
            layer.fillColor = minuteClockIndexColor.cgColor
            let margin = radius - (clockBorderWidth + 8)
            let path = UIBezierPath()
            for i in 0..<60 where (i%5 != 0) {
                let angle = Float(Double.pi/30)*Float(i)
                let cicle = UIBezierPath()
                let point = CGPoint(x: clockCenter.x + margin * CGFloat(cosf(angle)), y: clockCenter.y + margin * CGFloat(sinf(angle)))
                cicle.fill()
                cicle.addArc(withCenter: point, radius: minuteClockIndexWidth, startAngle: convert(0), endAngle: convert(360), clockwise: true)
                path.append(cicle)
            }
            
            layer.path = path.cgPath
            return layer
            
        }()
        layer.addSublayer(smallClockIndexLayer)
        setupMinuteLabel(layer: layer)
        
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
    private func setupMinuteLabel(layer: CAShapeLayer) {
        let margin = radius - (clockBorderWidth + 8)
        
        for i in 0..<12 {
            let label = { () -> CATextLayer in
                let label = CATextLayer()
                label.string = String(i*5)
                let size = String(i*5).size(withAttributes: [.font: clockMinuteFont])
                label.frame =  CGRect(origin: .zero, size: size)
                label.alignmentMode = .center
                label.fontSize = clockMinuteFont.pointSize
                label.font = clockMinuteFont
                label.foregroundColor = minuteLabelTextColor.cgColor
                return label
            }()
            
            
            let angle = angle270 + Float(i) * angle30
            let point = CGPoint(x: clockCenter.x + margin * CGFloat(cosf(angle)), y: clockCenter.y + margin * CGFloat(sinf(angle)))
            label.position = point
            layer.addSublayer(label)
        }
    }
    private func setupTimeLabel(layer: CAShapeLayer) {
        let margin = radius - (clockBorderWidth + 40)
        
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
            let point = CGPoint(x: clockCenter.x + margin * CGFloat(cosf(angle)), y: clockCenter.y + margin * CGFloat(sinf(angle)))
            label.position = point
            layer.addSublayer(label)
        }
    }
}
#endif
