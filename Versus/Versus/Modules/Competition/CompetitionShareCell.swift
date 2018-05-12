//
//  CompetitionShareCell.swift
//  Versus
//
//  Created by JT Smrdel on 5/11/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class CompetitionShareCell: UICollectionViewCell {
    
    @IBOutlet weak var shareImageView: CircleImageView!
    @IBOutlet weak var shareTitleLabel: UILabel!
    
    func configureCell(shareIcon: ShareIcon) {
        
        shareImageView.image = UIImage(named: shareIcon.imageName)
        shareTitleLabel.text = shareIcon.title
    }
}
