//
//  CategorySelectorCell.swift
//  Versus
//
//  Created by JT Smrdel on 3/27/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

class CategorySelectorCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func addConstraints(categorySelectorView: UIView) {
        
        contentView.addConstraint(
            NSLayoutConstraint(
                item: categorySelectorView,
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
                item: categorySelectorView,
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
                item: categorySelectorView,
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
                item: categorySelectorView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0.0
            )
        )
    }
    
    func configureCell(categorySelectorView: UIView) {
        contentView.addSubview(categorySelectorView)
        categorySelectorView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(categorySelectorView: categorySelectorView)
        categorySelectorView.layoutIfNeeded()
    }
}
