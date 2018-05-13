//
//  LeaderboardCell.swift
//  Versus
//
//  Created by JT Smrdel on 5/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class LeaderboardCell: UICollectionViewCell {
    
    @IBOutlet weak var leaderboardImageView: CircleImageView!
    @IBOutlet weak var leaderboardTitleLabel: UILabel!
    
    func configureCell(title: String) {
        leaderboardTitleLabel.text = title.replacingOccurrences(of: " ", with: "\n")
    }
}
