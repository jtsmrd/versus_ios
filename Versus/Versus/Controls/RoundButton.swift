//
//  RoundedButton.swift
//  Versus
//
//  Created by JT Smrdel on 3/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    @IBInspectable var _hasBorder = false
    @IBInspectable var _borderColor: UIColor = UIColor.white
    @IBInspectable var _borderWidth: CGFloat = 5.0
    @IBInspectable var _cornerRadius: CGFloat = 5.0
    
    override func prepareForInterfaceBuilder() {
        setupButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupButton()
    }
    
    func setupButton() {
        
        clipsToBounds = true
        layer.cornerRadius = _cornerRadius
        
        if _hasBorder {
            layer.borderColor = _borderColor.cgColor
            layer.borderWidth = _borderWidth
        }
    }
}
