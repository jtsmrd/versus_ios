//
//  LeaderboardHeaderImageCell.swift
//  Versus
//
//  Created by JT Smrdel on 7/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class LeaderboardHeaderImageCell: UITableViewCell {

    @IBOutlet weak var leaderboardHeaderImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(headerImage: UIImage) {
        leaderboardHeaderImageView.image = headerImage
    }
}
