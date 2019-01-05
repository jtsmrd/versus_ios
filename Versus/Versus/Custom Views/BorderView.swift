//
//  BorderView.swift
//  Versus
//
//  Created by JT Smrdel on 4/3/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

@IBDesignable
class BorderView: UIView {

    @IBInspectable var _cornerRadius: CGFloat = 10.0
    @IBInspectable var _hasBorder: Bool = false
    @IBInspectable var _borderColor: UIColor = UIColor.lightGray
    @IBInspectable var _borderWidth: CGFloat = 3.0
    
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    private func setupView() {
        clipsToBounds = true
        layer.cornerRadius = _cornerRadius
        
        if _hasBorder {
            layer.borderColor = _borderColor.cgColor
            layer.borderWidth = _borderWidth
        }
    }
}
