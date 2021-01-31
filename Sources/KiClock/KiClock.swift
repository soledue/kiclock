//
//  KIClock.swift
//
//  Created by Ivailo Kanev on 24/01/21.
//
#if os(iOS)
import UIKit

@objc
public protocol KiClockDelegate: class {
    @objc func kiClock(view: KiClock, didChangeDate: Date)
}
@IBDesignable
open class KiClock: UIView {
    // MARK: - Pubic properties
    @objc open weak var delegate: KiClockDelegate? {
        set {
            clockView.delegate = newValue
        }
        get {
            return clockView.delegate
        }
    }
    open var face: KiClockFaceProtocol? {
        set {
            clockView.face = newValue
        }
        get {
            return clockView.face
        }
    }
    open var timeZone: TimeZone?
    open var currentDate = Date()
    
    @IBInspectable
    open var hourHandWidth: CGFloat {
        set {
            clockView.hourHandWidth = newValue
        }
        get {
            return clockView.hourHandWidth
        }
    }
    @IBInspectable
    open var minuteHandWidth: CGFloat {
        set {
            clockView.minuteHandWidth = newValue
        }
        get {
            return clockView.minuteHandWidth
        }
    }
    @IBInspectable
    open var hourHandColor: UIColor {
       set {
            clockView.hourHandColor = newValue
        }
        get {
            return clockView.hourHandColor
        }
    }
    @IBInspectable
    open var minuteHandColor: UIColor {
        set {
            clockView.minuteHandColor = newValue
        }
        get {
            return clockView.minuteHandColor
        }
    }
    
    // MARK: - Private var
    private let clockView = KiClockView()
    
    // MARK: - Initialize
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    convenience init() {
        self.init(frame: .zero)
    }
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        clockView.redrawClock()
    }
    // MARK: - Setup
    private func setup() {
        `default`()
        addSubview(clockView)
        clockView.translatesAutoresizingMaskIntoConstraints = false
        clockView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        clockView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        clockView.widthAnchor.constraint(equalTo: clockView.heightAnchor).isActive = true
        
        
        let width = clockView.widthAnchor.constraint(equalTo: widthAnchor)
        width.priority = UILayoutPriority(rawValue: 750)
        width.isActive = true
        
        
        let height = clockView.heightAnchor.constraint(equalTo: heightAnchor)
        height.priority = UILayoutPriority(rawValue: 750)
        height.isActive = true
        
        clockView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor).isActive = true
        clockView.widthAnchor.constraint(lessThanOrEqualTo: heightAnchor).isActive = true
        clockView.hourHandWidth = hourHandWidth
        clockView.minuteHandWidth = minuteHandWidth
        clockView.hourHandColor = hourHandColor
        clockView.minuteHandColor = minuteHandColor
        clockView.redrawClock()
    }
    private func `default`() {
        hourHandWidth = 15.0
        minuteHandWidth = 8.0
        hourHandColor = .black
        minuteHandColor = .black
    }
}
private class KiClockView: UIView {
    weak var delegate: KiClockDelegate?
    var face: KiClockFaceProtocol?
    fileprivate var hourHandWidth: CGFloat = 15.0
    fileprivate var minuteHandWidth: CGFloat = 8.0
    fileprivate var hourHandColor: UIColor = .black
    fileprivate var minuteHandColor: UIColor = .black
    
    // MARK: - Private var
    private var hourHandView =  UIView()
    private var minuteHandView = UIView()
    private var radius: CGFloat {
        return bounds.width / 2
    }
    private var clockCenter: CGPoint {
        return CGPoint(x: radius, y: radius)
    }
    private var hourHandLength: CGFloat {
        return radius * 0.6
    }
    private var minuteHandLength: CGFloat {
        return radius * 0.8
    }
    private let handGestureWith: CGFloat = 30
    private let angle30 = Float(Double.pi / 6)
    private let angle180 = Float(Double.pi / 2)
    private let angle270 = Float(Double.pi + Double.pi/2)
    private let angle360 = Float(Double.pi * 2)
    private let anglePerHour = Float(Double.pi * 2) / 12
    private let anglePerMinute = Float(Double.pi * 2) / 60
    private var startAngle: Float = 0.0
    private var endAngle: Float = 0.0
    private var currentHourAngle: Float {
        return calculateAngle(hour: currentHour)
    }
    private var currentMinuteAngle: Float {
        return angle270 + anglePerMinute * Float(currentMinute)
    }
    private var currentMinute: Int {
        return currentComponents.minute!
    }
    var formattedTime: String {
        return dateFormatter.string(from: currentDate)
    }
    
    private var currentHour: Int {
        return currentComponents.hour!
    }
    private var currentComponents: DateComponents {
        return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second],  from: currentDate)
    }
    var timeZone: TimeZone? {
        didSet {
            if let timeZone = timeZone {
                calendar.timeZone = timeZone
                dateFormatter.timeZone = timeZone
            } else {
                calendar.timeZone = .current
                dateFormatter.timeZone = .current
            }
        }
    }
    private var calendar = Calendar(identifier: .gregorian)
    private let dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
    fileprivate var currentDate = Date()
    // MARK: - Lifecicle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        redrawClock()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        redrawClock()
    }
    // MARK: - Public
    public func redrawClock() {
        relodClock()
        drawMinuteHandLayer(angle: currentMinuteAngle)
        drawHourHandLayer(angle: currentHourAngle)
    }
    // MARK: - Private
    private func clear() {
        subviews.forEach { $0.removeFromSuperview() }
        layer.sublayers?.forEach( { $0.removeFromSuperlayer() })
    }
    private func relodClock() {
        clear()
        let face = self.face ?? KiDefaultFace(bounds: bounds)
        if let bottom = face.bottomLayer {
            layer.addSublayer(bottom)
        }
        
        hourHandView = { () -> UIView in
            let hourHandView = UIView(frame: CGRect(x: 0, y: 0, width: handGestureWith, height: hourHandLength))
            let hourHandInsideView = UIView(frame: CGRect(x: (handGestureWith - hourHandWidth) / 2, y: 0, width: hourHandWidth, height: hourHandLength))
            hourHandInsideView.layer.cornerRadius = hourHandWidth / 2
            hourHandInsideView.backgroundColor = hourHandColor
            let pan = UIPanGestureRecognizer(target: self, action: #selector(hourAction(gesture:)))
            hourHandView.addSubview(hourHandInsideView)
            hourHandView.addGestureRecognizer(pan)
            hourHandView.layer.anchorPoint = CGPoint(x:0.5, y:0)
            return hourHandView
        }()
        addSubview(hourHandView)
        
        minuteHandView = { () -> UIView in
            let minuteHandView = UIView(frame: CGRect(x: 0, y: 0, width: handGestureWith, height: minuteHandLength))
            let minuteHandInsideView = UIView(frame: CGRect(x: (handGestureWith - minuteHandWidth) / 2, y: 0, width: minuteHandWidth, height: minuteHandLength))
            minuteHandInsideView.layer.cornerRadius = minuteHandWidth / 2
            minuteHandInsideView.backgroundColor = minuteHandColor
            let pan = UIPanGestureRecognizer(target: self, action: #selector(minuteAction(gesture:)))
            minuteHandView.addSubview(minuteHandInsideView)
            minuteHandView.addGestureRecognizer(pan)
            minuteHandView.layer.anchorPoint = CGPoint(x:0.5, y:0)
            return minuteHandView
        }()
        addSubview(minuteHandView)
        
        minuteHandView.center = convert(center, from: superview)
        hourHandView.center = convert(center, from: superview)
        
        if let top = face.topLayer {
            layer.addSublayer(top)
        }
    }
    
    private func calculateAngle(hour: Int) -> Float {
        let hourInt = hour > 12 ? hour - 12 : hour
        let hourAngle = angle270 + anglePerHour * Float(hourInt)
        return hourAngle + ((Float(currentMinute)/60.0) * anglePerHour)
    }
    private func calculateHourAngle(point: CGPoint, radius: CGFloat) -> Float {
        let radian = calculateRadian(point: point, radius: radius)
        let hour = Int((radian - angle270) / anglePerHour)
        return calculateAngle(hour: hour)
    }
    private func calculateRadian(point: CGPoint, radius: CGFloat) -> Float {
        let centerPoint = CGPoint(x: radius, y: radius)
        
        let x = Float(point.x - centerPoint.x)
        let y = -Float(point.y - centerPoint.y)
        
        var radian = atan2f(y, x)
        
        radian = radian * -1
        if radian < 0 {
            radian += angle360
        }
        
        if radian >= 0 && radian < angle270 {
            radian += angle360
        }
        return radian
    }
    private func calculateMinute(point: CGPoint, radius: CGFloat) -> Int {
        let radian = calculateRadian(point: point, radius: radius)
        return Int((radian - angle270) / anglePerMinute)
    }
    private func appendHour(_ hour: Int) {
        currentDate = currentDate.addingTimeInterval(60 * 60 * Double(hour))
    }
    private func calculateElapsedTime(startAngle: Float, endAngle: Float) -> Int {
        var angleGap: Float = 0.0
        if startAngle > endAngle {
            let gap = startAngle - endAngle
            if gap > angle270 {
                angleGap = (endAngle + angle360) - startAngle
            } else {
                angleGap = endAngle - startAngle
            }
        } else {
            let gap = endAngle - startAngle
            if gap > angle270 {
                angleGap = ((startAngle + angle360) - endAngle) * -1
            } else {
                angleGap = endAngle - startAngle
            }
        }
        
        var degree = Int(angleGap*360 / angle360)
        degree = (degree < 0) ? degree - 5 : degree + 5
        let hour: Int = degree/30
        return hour
    }
    private func updateCurrentDate(minute: Int) {
        var components = currentComponents
        components.minute = minute
        currentDate = calendar.date(from: components)!
    }
    private func revisedByAcrossHour(startAngle: Float, endAngle: Float) {
        if endAngle < startAngle {
            let gap = startAngle - endAngle
            if gap > angle270 {
                appendHour(1)
            }
        } else {
            let gap = endAngle - startAngle
            if gap > angle270 {
                appendHour(-1)
            }
        }
    }
    private func drawMinuteHandLayer(angle: Float) {
        let rotation = angle - angle180
        minuteHandView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
    }
    
    private func drawHourHandLayer(angle: Float) {
        let rotation = angle - angle180
        hourHandView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
    }
    private func changedTime() {
        delegate?.kiClock(view: superview as! KiClock, didChangeDate: currentDate)
    }
    //MARK: - Gesture Action
    @objc
    func hourAction(gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self)
        if gesture.state == .began {
            startAngle = currentHourAngle
        } else {
            endAngle = calculateHourAngle(point: point, radius: radius)
            if startAngle == endAngle {
                return
            }
            
            let hour = calculateElapsedTime(startAngle: startAngle, endAngle: endAngle)
            appendHour(hour)
            drawHourHandLayer(angle: currentHourAngle)
            changedTime()
            startAngle = endAngle
        }
    }
    @objc
    func minuteAction(gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: self)
        if gesture.state == .began {
            startAngle = currentMinuteAngle
        } else {
            let minuteInt = calculateMinute(point: point, radius: radius)
            if minuteInt == currentMinute {
                return
            }
            updateCurrentDate(minute: minuteInt)
            endAngle = currentMinuteAngle
            revisedByAcrossHour(startAngle: startAngle, endAngle: endAngle)
            drawMinuteHandLayer(angle: currentMinuteAngle)
            drawHourHandLayer(angle: currentHourAngle)
            changedTime()
            startAngle = endAngle
            
        }
    }
}
#endif
