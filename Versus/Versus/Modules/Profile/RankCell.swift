//
//  RankCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class RankCell: UITableViewCell {

    
    @IBOutlet weak var userRankView: UserRankView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var rankTitleLabel: UILabel!
    @IBOutlet weak var winsRequirementLabel: UILabel!
    @IBOutlet weak var votesRequirementLabel: UILabel!
    @IBOutlet weak var rankImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureCell(user: User, rank: Rank) {
        
        userRankView.isHidden = user.rankId != rank.id
        profileImageView.image = user.profileImage
        winsLabel.text = String(format: "%d Wins", user.totalWins)        
        votesLabel.text = String(format: "%d Votes", user.totalTimesVoted)
        rankTitleLabel.text = rank.title
        winsRequirementLabel.text = "10+ Wins"
        votesRequirementLabel.text = "10+ Votes"
        rankImageView.image = UIImage(named: rank.imageName)
    }
}
