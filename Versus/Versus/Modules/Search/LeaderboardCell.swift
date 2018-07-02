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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        leaderboardImageView.image = UIImage(named: "default-profile")
    }
    
    
    func configureCell(leaderboard: Leaderboard) {
        leaderboardTitleLabel.text = leaderboard.leaderboardName.replacingOccurrences(of: " ", with: "\n")
        
        leaderboard.getLeaders { (success, customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.parentViewController?.displayError(error: customError)
                }
                else if success {
                    leaderboard.getFeaturedLeaderImage(completion: { (image) in
                        DispatchQueue.main.async {
                            self.leaderboardImageView.image = image ?? UIImage(named: "default-profile")
                        }
                    })
                }
            }
        }
    }
}
