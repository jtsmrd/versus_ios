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

    @IBInspectable var _backgroundColor: UIColor = UIColor.white
    @IBInspectable var _hasBorder: Bool = false
    @IBInspectable var _borderColor: UIColor = UIColor.lightGray
    @IBInspectable var _borderWidth: CGFloat = 3.0
    
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
    
    private func setupButton() {
        clipsToBounds = true
        layer.cornerRadius = bounds.width / 2
        layer.backgroundColor = _backgroundColor.cgColor
        
        if _hasBorder {
            layer.borderColor = _borderColor.cgColor
            layer.borderWidth = _borderWidth
        }
    }
}
