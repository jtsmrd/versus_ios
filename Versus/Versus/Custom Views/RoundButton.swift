//
//  RoundButton.swift
//  Versus
//
// Custom button for rounding corners and optionally configuring a border.
//
//  Created by JT Smrdel on 3/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    @IBInspectable var _cornerRadius: CGFloat = 10.0
    @IBInspectable var _hasBorder: Bool = false
    @IBInspectable var _borderColor: UIColor = UIColor.white
    @IBInspectable var _borderWidth: CGFloat = 3.0
    
    override func draw(_ rect: CGRect) {
        setupButton()
    }
    
    override func prepareForInterfaceBuilder() {
        setupButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    private func setupButton() {
        clipsToBounds = true
        layer.cornerRadius = _cornerRadius
        
        if _hasBorder {
            layer.borderColor = _borderColor.cgColor
            layer.borderWidth = _borderWidth
        }
        else {
            layer.borderColor = nil
            layer.borderWidth = 0
        }
    }
}
