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
    @IBOutlet weak var leftEntryImageView: UIImageView!
    @IBOutlet weak var leftImageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var leftEntryRankImageView: UIImageView!
    @IBOutlet weak var leftEntryUsernameLabel: UILabel!
    @IBOutlet weak var leftEntryVotesLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var rightEntryImageView: UIImageView!
    @IBOutlet weak var rightImageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rightEntryRankImageView: UIImageView!
    @IBOutlet weak var rightEntryUsernameLabel: UILabel!
    @IBOutlet weak var rightEntryVotesLabel: UILabel!
    
    private let s3BucketService = S3BucketService.instance
    
    private var competition: Competition?
    
    /**
 
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        categoryImageView.image = nil
        leftEntryImageView.image = UIImage(named: "default-profile")
        leftEntryRankImageView.image = nil
        leftEntryUsernameLabel.text = nil
        leftEntryVotesLabel.text = nil
        rightEntryImageView.image = UIImage(named: "default-profile")
        rightEntryRankImageView.image = nil
        rightEntryUsernameLabel.text = nil
        rightEntryVotesLabel.text = nil
        competition = nil
    }
    
    
    func updateImages() {
        
        if let image = competition?.leftEntry.image {
            leftEntryImageView.image = image
            leftImageActivityIndicator.stopAnimating()
        }
        
        if let image = competition?.rightEntry.image {
            rightEntryImageView.image = image
            rightImageActivityIndicator.stopAnimating()
        }
    }
    
    
    /**
     
     */
    func configureCell(
        competition: Competition
    ) {
        self.competition = competition
        versusCircleView._backgroundColor = competition.category.backgroundColor
        versusCircleView.setNeedsDisplay()
        
        categoryBarView.backgroundColor = competition.category.backgroundColor
        categoryImageView.image = competition.category.iconImage
        
        leftEntryRankImageView.image = competition.leftEntry.rank.image
        rightEntryRankImageView.image = competition.rightEntry.rank.image
        
        leftEntryUsernameLabel.text = String(
            format: "@%@",
            competition.leftEntry.user.username
        )
        rightEntryUsernameLabel.text = String(
            format: "@%@",
            competition.rightEntry.user.username
        )
        
        leftEntryVotesLabel.text = String(
            format: "%d",
            competition.leftEntry.voteCount
        )
        rightEntryVotesLabel.text = String(
            format: "%d",
            competition.rightEntry.voteCount
        )
        
        leftImageActivityIndicator.startAnimating()
        if let image = competition.leftEntry.image {
            leftEntryImageView.image = image
            leftImageActivityIndicator.stopAnimating()
        }
        
        rightImageActivityIndicator.startAnimating()
        if let image = competition.rightEntry.image {
            rightEntryImageView.image = image
            rightImageActivityIndicator.stopAnimating()
        }
    }
}
