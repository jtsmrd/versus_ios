//
//  SwiftyCamProgressButton.swift
//  Versus
//
//  Created by JT Smrdel on 4/24/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import SwiftyCam

@IBDesignable
class SwiftyCamProgressButton: SwiftyCamButton {

    @IBInspectable var _backgroundColor: UIColor = UIColor.groupTableViewBackground
    @IBInspectable var _progressIndicatorColor: UIColor = UIColor.red
    @IBInspectable var _progressIndicatorLineWidth: CGFloat = 5.0
    
    private var backgroundCirclePathLayer: CAShapeLayer!
    private var progressCirclePathLayer: CAShapeLayer!
    private var circlePathFrame: CGRect = CGRect.zero
    private let circlePathDelta: CGFloat = 3
    private var circleRadius: CGFloat = 0
    private var animation: CABasicAnimation!
    
    override func prepareForInterfaceBuilder() {
        setupButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
    }
    
    
    private func setupButton() {
        
        clipsToBounds = true
        layer.cornerRadius = bounds.width / 2
        backgroundColor = _backgroundColor
        
        circleRadius = bounds.width / 2
        
        circlePathFrame = CGRect(
            x: circlePathDelta,
            y: circlePathDelta,
            width: bounds.width - (circlePathDelta * 2),
            height: bounds.height - (circlePathDelta * 2)
        )
        
        backgroundCirclePathLayer = CAShapeLayer()
        backgroundCirclePathLayer.strokeEnd = 1
        backgroundCirclePathLayer.frame = circlePathFrame
        backgroundCirclePathLayer.path = createCirclePath(bounds: backgroundCirclePathLayer.bounds)
        backgroundCirclePathLayer.lineWidth = _progressIndicatorLineWidth
        backgroundCirclePathLayer.fillColor = UIColor.clear.cgColor
        backgroundCirclePathLayer.strokeColor = UIColor.white.cgColor
        layer.addSublayer(backgroundCirclePathLayer)
        
        progressCirclePathLayer = CAShapeLayer()
        progressCirclePathLayer.strokeEnd = 0
        progressCirclePathLayer.frame = circlePathFrame
        progressCirclePathLayer.path = createCirclePath(bounds: progressCirclePathLayer.bounds)
        progressCirclePathLayer.lineWidth = _progressIndicatorLineWidth
        progressCirclePathLayer.fillColor = UIColor.clear.cgColor
        progressCirclePathLayer.strokeColor = _progressIndicatorColor.cgColor
        layer.addSublayer(progressCirclePathLayer)
    }
    
    private func createCirclePath(bounds: CGRect) -> CGPath {
        
        var circleFrame = circlePathFrame
        let circlePathBounds = bounds
        circleFrame.origin.x = (circlePathBounds.midX - circleFrame.midX) + circlePathDelta
        circleFrame.origin.y = (circlePathBounds.midY - circleFrame.midY) + circlePathDelta
        
        let path = UIBezierPath(
            arcCenter: CGPoint(
                x: circlePathBounds.midX,
                y: circlePathBounds.midY
            ),
            radius: circleFrame.height / 2,
            startAngle: CGFloat(CGFloat.pi / 2) * 3.0,
            endAngle: CGFloat(CGFloat.pi / 2) * 3.0 + CGFloat(CGFloat.pi) * 2.0,
            clockwise: true
        )
        return path.cgPath
    }
    
    func beginAnimatingProgress() {
        
        animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 60
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.fillMode = CAMediaTimingFillMode.removed // keep to value after finishing
        animation.isRemovedOnCompletion = true // don't remove after finishing
        progressCirclePathLayer.add(animation, forKey: animation.keyPath)
    }
    
    func endAnimatingProgress() {
        
        progressCirclePathLayer.removeAnimation(forKey: animation.keyPath!)
        progressCirclePathLayer.strokeEnd = 0
    }
}
