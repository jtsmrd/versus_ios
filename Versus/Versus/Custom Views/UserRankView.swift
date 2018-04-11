//
//  UserRankView.swift
//  Versus
//
//  Created by JT Smrdel on 4/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

@IBDesignable
class UserRankView: UIView {

    @IBInspectable var _backgroundColor: UIColor = UIColor.white
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        setupView()
    }
 
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    private func setupView() {
        clipsToBounds = true
        let path = createBezierPath()
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        
        path.apply(CGAffineTransform(translationX: 0, y: 0))
        _backgroundColor.setFill()
        path.fill()
    }
    
    private func createBezierPath() -> UIBezierPath {
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: frame.height))                       // Bottom left
        path.addLine(to: CGPoint(x: 0, y: 0))                               // Top left
        path.addLine(to: CGPoint(x: frame.width * 0.85, y: 0))              // Top right
        path.addLine(to: CGPoint(x: frame.width, y: frame.height / 2))      // Center vertex
        path.addLine(to: CGPoint(x: frame.width * 0.85, y: frame.height))   // Top right
        path.addLine(to: CGPoint(x: 0, y: frame.height))                    // Bottom left
        path.close()
        return path
    }
}
