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
    @IBInspectable var _progressIndicatorLineWidth: CGFloat = 3.0
    
    let circlePathLayer = CAShapeLayer()
    var circlePathFrame: CGRect = CGRect.zero
    let circlePathDelta: CGFloat = 3
    var circleRadius: CGFloat = 0
    let centerView = CircleView()
    var animation: CABasicAnimation!
    
    override func prepareForInterfaceBuilder() {
        setupButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathFrame = CGRect(x: circlePathDelta, y: circlePathDelta, width: bounds.width - (circlePathDelta * 2), height: bounds.height - (circlePathDelta * 2))
        circlePathLayer.frame = circlePathFrame
        centerView.frame = circlePathFrame
        circlePathLayer.path = circlePath().cgPath
        layer.cornerRadius = bounds.width / 2
        circleRadius = bounds.width / 2
    }
    
    func setupButton() {
        
        circlePathLayer.strokeEnd = 0
        
        circlePathFrame = CGRect(x: circlePathDelta, y: circlePathDelta, width: bounds.width - (circlePathDelta * 2), height: bounds.height - (circlePathDelta * 2))
        clipsToBounds = true
        layer.cornerRadius = bounds.width / 2
        circleRadius = bounds.width / 2
        
        centerView.frame = circlePathFrame
        layer.addSublayer(centerView.layer)
        
        circlePathLayer.frame = circlePathFrame
        circlePathLayer.lineWidth = _progressIndicatorLineWidth
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = _progressIndicatorColor.cgColor
        layer.addSublayer(circlePathLayer)
        backgroundColor = _backgroundColor
    }
    
    func circlePath() -> UIBezierPath {
        
        var circleFrame = circlePathFrame
        let circlePathBounds = circlePathLayer.bounds
        circleFrame.origin.x = (circlePathBounds.midX - circleFrame.midX) + circlePathDelta
        circleFrame.origin.y = (circlePathBounds.midY - circleFrame.midY) + circlePathDelta
        
        let path = UIBezierPath(arcCenter: CGPoint(x: circlePathBounds.midX, y: circlePathBounds.midY), radius: circleFrame.height / 2, startAngle: CGFloat(CGFloat.pi / 2) * 3.0, endAngle: CGFloat(CGFloat.pi / 2) * 3.0 + CGFloat(CGFloat.pi) * 2.0, clockwise: true)
        return path
    }
    
    func animateTimeRemaining() {
        
        animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 60
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fillMode = kCAFillModeRemoved // keep to value after finishing
        animation.isRemovedOnCompletion = true // don't remove after finishing
        circlePathLayer.add(animation, forKey: animation.keyPath)
    }
    
    func stopAnimatingTimeRemaining() {
        
        circlePathLayer.removeAnimation(forKey: animation.keyPath!)
        circlePathLayer.strokeEnd = 0
    }
}
