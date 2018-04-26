//
//  CompetitionCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class CompetitionCell: UITableViewCell {

    
    @IBOutlet weak var versusCircleView: CircleView!
    @IBOutlet weak var categoryBarView: UIView!
    @IBOutlet weak var user1ImageView: UIImageView!
    @IBOutlet weak var user1RankImageView: UIImageView!
    @IBOutlet weak var user1UsernameLabel: UILabel!
    @IBOutlet weak var user1VotesLabel: UILabel!
    @IBOutlet weak var competitionCategoryImageView: UIImageView!
    @IBOutlet weak var user2ImageView: UIImageView!
    @IBOutlet weak var user2RankImageView: UIImageView!
    @IBOutlet weak var user2UsernameLabel: UILabel!
    @IBOutlet weak var user2VotesLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(competition: Competition) {
        
        competition.getUser1CompetitionImage { (competitionImage) in
            DispatchQueue.main.async {
                self.user1ImageView.image = competitionImage
            }
        }
        
        competition.getUser2CompetitionImage { (competitionImage) in
            DispatchQueue.main.async {
                self.user2ImageView.image = competitionImage
            }
        }
        
        versusCircleView._backgroundColor = competition.competitionCategoryColor
        categoryBarView.backgroundColor = competition.competitionCategoryColor
        competitionCategoryImageView.image = competition.competitionCategoryIconImage
        
        user1RankImageView.image = competition.user1RankImage
        user1UsernameLabel.text = competition.user1Username
        
        user2RankImageView.image = competition.user2RankImage
        user2UsernameLabel.text = competition.user2Username
    }
}
