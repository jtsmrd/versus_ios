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
    @IBOutlet weak var firstEntryCompetitionImageView: UIImageView!
    @IBOutlet weak var firstEntryUserRankImageView: UIImageView!
    @IBOutlet weak var firstEntryUsernameLabel: UILabel!
    @IBOutlet weak var firstEntryVotesLabel: UILabel!
    @IBOutlet weak var competitionCategoryImageView: UIImageView!
    @IBOutlet weak var secondEntryCompetitionImageView: UIImageView!
    @IBOutlet weak var secondEntryUserRankImageView: UIImageView!
    @IBOutlet weak var secondEntryUsernameLabel: UILabel!
    @IBOutlet weak var secondEntryVotesLabel: UILabel!
    
    
    /**
 
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        competitionCategoryImageView.image = nil
        firstEntryCompetitionImageView.image = nil
        firstEntryUserRankImageView.image = nil
        firstEntryUsernameLabel.text = nil
        firstEntryVotesLabel.text = nil
        secondEntryCompetitionImageView.image = nil
        secondEntryUserRankImageView.image = nil
        secondEntryUsernameLabel.text = nil
        secondEntryVotesLabel.text = nil
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    /**
     
     */
    func configureCell(competition: Competition) {
        versusCircleView._backgroundColor = competition.category.backgroundColor
        versusCircleView.setNeedsDisplay()
        categoryBarView.backgroundColor = competition.category.backgroundColor
        competitionCategoryImageView.image = competition.category.iconImage
        firstEntryUserRankImageView.image = competition.firstCompetitor.rank.image
        firstEntryUsernameLabel.text = String(format: "@%@", competition.firstCompetitor.username)
        firstEntryVotesLabel.text = String(format: "%d", competition.firstCompetitor.voteCount)
        secondEntryUserRankImageView.image = competition.secondCompetitor.rank.image
        secondEntryUsernameLabel.text = String(format: "@%@", competition.secondCompetitor.username)
        secondEntryVotesLabel.text = String(format: "%d", competition.secondCompetitor.voteCount)
        
        
        // TODO: Remove and use operation queue.
        DispatchQueue.global(qos: .userInitiated).async {
            
            S3BucketService.instance.downloadImage(mediaId: competition.firstCompetitor.mediaId, imageType: .regular, completion: { [weak self] (image, customError) in
                
                DispatchQueue.main.async {
                    self?.firstEntryCompetitionImageView.image = image
                }
            })
        }
        
        // TODO: Remove and use operation queue.
        DispatchQueue.global(qos: .userInitiated).async {
            
            S3BucketService.instance.downloadImage(mediaId: competition.secondCompetitor.mediaId, imageType: .regular, completion: { [weak self] (image, customError) in
                
                DispatchQueue.main.async {
                    self?.secondEntryCompetitionImageView.image = image
                }
            })
        }
    }
}
