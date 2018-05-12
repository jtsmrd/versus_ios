//
//  CompetitionOptionCell.swift
//  Versus
//
//  Created by JT Smrdel on 5/11/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class CompetitionOptionCell: UICollectionViewCell {
    
    @IBOutlet weak var optionImageView: CircleImageView!
    @IBOutlet weak var optionTitleLabel: UILabel!
    
    func configureCell(optionIcon: OptionIcon) {
        
        optionImageView.image = UIImage(named: optionIcon.imageName)
        optionTitleLabel.text = optionIcon.title
    }
}
