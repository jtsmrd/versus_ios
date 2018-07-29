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
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(competition: Competition) {
        
        switch competition.competitionType {
        case .image:
            
            DispatchQueue.global(qos: .userInitiated).async {
                competition.getCompetitionImage(for: .user1, bucketType: .competitionImageSmall) { (image, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.parentViewController?.displayError(error: error)
                        }
                        else {
                            self.user1ImageView.image = image
                        }
                    }
                }
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                competition.getCompetitionImage(for: .user2, bucketType: .competitionImageSmall) { (image, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.parentViewController?.displayError(error: error)
                        }
                        else {
                            self.user2ImageView.image = image
                        }
                    }
                }
            }
            
        case .video:
            
            DispatchQueue.global(qos: .userInitiated).async {
                competition.getCompetitionImage(for: .user1, bucketType: .competitionVideoPreviewImageSmall) { (image, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.parentViewController?.displayError(error: error)
                        }
                        else {
                            self.user1ImageView.image = image
                        }
                    }
                }
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                competition.getCompetitionImage(for: .user2, bucketType: .competitionVideoPreviewImageSmall) { (image, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.parentViewController?.displayError(error: error)
                        }
                        else {
                            self.user2ImageView.image = image
                        }
                    }
                }
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            CompetitionVoteService.instance.getVoteCountFor(competition.awsCompetition._user1CompetitionEntryId!) { (voteCount, customError) in
                DispatchQueue.main.async {
                    if let _ = customError {
                        debugPrint("Error getting votes for user1")
                    }
                    else if let voteCount = voteCount {
                        self.user1VotesLabel.text = String(format: "%i", voteCount)
                    }
                    else {
                        self.user1VotesLabel.text = "--"
                    }
                }
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            CompetitionVoteService.instance.getVoteCountFor(competition.awsCompetition._user2CompetitionEntryId!) { (voteCount, customError) in
                DispatchQueue.main.async {
                    if let _ = customError {
                        debugPrint("Error getting votes for user1")
                    }
                    else if let voteCount = voteCount {
                        self.user2VotesLabel.text = String(format: "%i", voteCount)
                    }
                    else {
                        self.user2VotesLabel.text = "--"
                    }
                }
            }
        }
        
        
        
        versusCircleView._backgroundColor = competition.competitionCategoryColor
        versusCircleView.setNeedsDisplay()
        categoryBarView.backgroundColor = competition.competitionCategoryColor
        competitionCategoryImageView.image = competition.competitionCategoryIconImage
        
        user1RankImageView.image = competition.userRankImage(for: .user1)
        user1UsernameLabel.text = competition.username(for: .user1)
        
        user2RankImageView.image = competition.userRankImage(for: .user2)
        user2UsernameLabel.text = competition.username(for: .user2)
    }
}
