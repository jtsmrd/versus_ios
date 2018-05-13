//
//  ProgressIndicatorButton.swift
//  Versus
//
//  Created by JT Smrdel on 4/27/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

@IBDesignable
class ProgressIndicatorButton: UIButton {

    @IBInspectable var _backgroundColor: UIColor = UIColor.groupTableViewBackground
    @IBInspectable var _progressIndicatorColor: UIColor = UIColor.red
    @IBInspectable var _progressIndicatorLineWidth: CGFloat = 3.0
    @IBInspectable var _imageView: CircleImageView = CircleImageView(image: UIImage(named: "default-profile"))
    
    let circlePathLayer = CAShapeLayer()
    var circlePathFrame: CGRect = CGRect.zero
    let circlePathDelta: CGFloat = 3
    var circleRadius: CGFloat = 0
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if newValue > 1 {
                circlePathLayer.strokeEnd = 1
            } else if newValue < 0 {
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
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
        _imageView.frame = circlePathFrame
        circlePathLayer.path = circlePath().cgPath
        layer.cornerRadius = bounds.width / 2
        circleRadius = bounds.width / 2
    }

    func setupButton() {
        
        progress = 0
        
        circlePathFrame = CGRect(x: circlePathDelta, y: circlePathDelta, width: bounds.width - (circlePathDelta * 2), height: bounds.height - (circlePathDelta * 2))
        clipsToBounds = true
        layer.cornerRadius = bounds.width / 2
        circleRadius = bounds.width / 2
        
        _imageView.contentMode = .scaleAspectFill
        _imageView.frame = circlePathFrame
        _imageView.backgroundColor = UIColor.clear
        layer.addSublayer(_imageView.layer)
        
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
        return UIBezierPath(ovalIn: circleFrame)
    }
    
    func updateProgress(percent: CGFloat) {
        progress = percent
    }
}
