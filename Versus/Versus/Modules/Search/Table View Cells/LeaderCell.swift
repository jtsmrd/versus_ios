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
    
    func configureCell(leader: Leader, rowNumber: Int) {
        
        leaderRankLabel.text = String(
            format: "%d",
            rowNumber
        )
        leaderUsernameLabel.text = leader.user.username
        leaderWinsLabel.text = String(
            format: "    %d wins",
            leader.winCount
        )
        leaderVotesLabel.text = String(
            format: "    %d votes",
            leader.voteCount
        )
        
        S3BucketService.instance.downloadImage(
            mediaId: leader.user.profileImage,
            imageType: .regular
        ) { (image, errorMessage) in

            DispatchQueue.main.async {

                if let errorMessage = errorMessage {
                    debugPrint(errorMessage)
                    return
                }

                self.leaderImageView.image = image
            }
        }
    }
}
