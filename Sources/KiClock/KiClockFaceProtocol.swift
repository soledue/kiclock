//
//  KIClockFaceProtocol.swift
//
//  Created by Ivailo Kanev on 24/01/21.
//
#if os(iOS)
import UIKit
public protocol KiClockFaceProtocol: class {
    var angle270: Float { get }
    var angle30 : Float { get }
    var angle180: Float { get }
    var angle360 : Float { get }
    var radius: CGFloat { get }
    var clockCenter: CGPoint { get }
    var bounds: CGRect{ get }
    func draw(bottom view: UIView)
    func draw(top view: UIView)
    func convert(_ degree: Double) -> CGFloat 

}
public extension KiClockFaceProtocol {
    var angle270: Float {
        Float(Double.pi + Double.pi/2)
    }
    var angle30: Float {
        Float(Double.pi / 6)
    }
    var angle180: Float {
        Float(Double.pi / 2)
    }
    var angle360: Float {
        Float(Double.pi * 2)
    }
    var radius: CGFloat {
        return bounds.width / 2
    }
    var clockCenter: CGPoint {
        return CGPoint(x: radius, y: radius)
    }
    init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func convert(_ degree: Double) -> CGFloat {
        return CGFloat(.pi * degree / 180.0)
    }
}
#endif
