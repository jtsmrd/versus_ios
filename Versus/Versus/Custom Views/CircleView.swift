//
//  CircleView.swift
//  Versus
//
//  Created by JT Smrdel on 4/5/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

@IBDesignable
class CircleView: UIView {

    @IBInspectable var _backgroundColor: UIColor = UIColor.white
    
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
    }
}
