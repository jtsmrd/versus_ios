//
//  ProfileInfoCell.swift
//  Versus
//
//  Created by JT Smrdel on 3/25/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

class ProfileInfoCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    private func addConstraints(profileInfoView: UIView) {
        
        contentView.addConstraint(
            NSLayoutConstraint(
                item: profileInfoView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .leading,
                multiplier: 1.0,
                constant: 0.0
            )
        )
        contentView.addConstraint(
            NSLayoutConstraint(
                item: profileInfoView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .trailing,
                multiplier: 1.0,
                constant: 0.0
            )
        )
        contentView.addConstraint(
            NSLayoutConstraint(
                item: profileInfoView,
                attribute: .top,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .top,
                multiplier: 1.0,
                constant: 0.0
            )
        )
        contentView.addConstraint(
            NSLayoutConstraint(
                item: profileInfoView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0.0
            )
        )
    }
    
    func configureCell(profileInfoView: UIView) {
        contentView.addSubview(profileInfoView)
        profileInfoView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(profileInfoView: profileInfoView)
        profileInfoView.layoutIfNeeded()
    }
}
