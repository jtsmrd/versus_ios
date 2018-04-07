//
//  CircleButton.swift
//  Versus
//
//  Created by JT Smrdel on 4/3/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

@IBDesignable
class CircleButton: UIButton {

    @IBInspectable var _backgroundColor: UIColor = UIColor.white
    @IBInspectable var _hasBorder: Bool = false
    @IBInspectable var _borderColor: UIColor = UIColor.lightGray
    @IBInspectable var _borderWidth: CGFloat = 3.0
    
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
