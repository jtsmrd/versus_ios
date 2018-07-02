//
//  LeaderCell.swift
//  Versus
//
//  Created by JT Smrdel on 6/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class LeaderCell: UITableViewCell {

    
    @IBOutlet weak var leaderRankLabel: UILabel!
    @IBOutlet weak var leaderImageView: CircleImageView!
    @IBOutlet weak var leaderUsernameLabel: UILabel!
    @IBOutlet weak var leaderWinsLabel: UILabel!
    @IBOutlet weak var leaderVotesLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(leader: Leader, leaderboardType: LeaderboardType, leaderRank: Int) {
        
        leaderRankLabel.text = String(format: "%i", leaderRank)
        leaderUsernameLabel.text = leader.username
        leaderWinsLabel.text = String(format: "    %i wins", leader.totalWins)
        leaderVotesLabel.text = String(format: "    %i votes", leader.totalVotes)
        
        S3BucketService.instance.downloadImage(
            imageName: leader.userPoolUserId,
            bucketType: .profileImageSmall
        ) { (image, error) in
            if let error = error {
                debugPrint("Could not load user profile image: \(error.localizedDescription)")
            }
            else if let image = image {
                DispatchQueue.main.async {
                    self.leaderImageView.image = image
                }
            }
        }
    }
}
