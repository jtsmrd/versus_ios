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
        
        S3BucketService.instance.downloadImage(imageName: competition.awsCompetition._user1ImageId!, bucketType: .competitionImage) { (image, error) in
            if let error = error {
                debugPrint("Could not download user1 competition image: \(error.localizedDescription)")
            }
            else if let image = image {
                DispatchQueue.main.async {
                    self.user1ImageView.image = image
                }
            }
        }
        
        S3BucketService.instance.downloadImage(imageName: competition.awsCompetition._user2ImageId!, bucketType: .competitionImage) { (image, error) in
            if let error = error {
                debugPrint("Could not download user1 competition image: \(error.localizedDescription)")
            }
            else if let image = image {
                DispatchQueue.main.async {
                    self.user2ImageView.image = image
                }
            }
        }
        
        user1UsernameLabel.text = "@\(competition.awsCompetition._user1Username!)"
        
        user2UsernameLabel.text = "@\(competition.awsCompetition._user2Username!)"
    }
}
