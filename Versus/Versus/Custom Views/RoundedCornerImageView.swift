//
//  RoundedCornerImageView.swift
//  Versus
//
//  Created by JT Smrdel on 5/17/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedCornerImageView: UIImageView {

    @IBInspectable var _cornerRadius: CGFloat = 5.0

    override func prepareForInterfaceBuilder() {
        setupImageView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView()
    }
    
    private func setupImageView() {
        clipsToBounds = true
        layer.cornerRadius = _cornerRadius
    }
}
