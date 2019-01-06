//
//  ProfileCompetitionCell.swift
//  Versus
//
//  Created by JT Smrdel on 5/9/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class ProfileCompetitionCell: UICollectionViewCell {
    
    @IBOutlet weak var competitionImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        competitionImageView.image = nil
    }
    
    
    func configureCell(competition: Competition, userId: String) {
        
        var currentUserCompetitorRecord: Competitor!
        if competition.firstCompetitor.userId == userId {
            currentUserCompetitorRecord = competition.firstCompetitor
        }
        else {
            currentUserCompetitorRecord = competition.secondCompetitor
        }
        
        
        // TODO: Remove and use operation queue
        DispatchQueue.global(qos: .userInitiated).async {
            
            S3BucketService.instance.downloadImage(mediaId: currentUserCompetitorRecord.mediaId, imageType: .small, completion: { [weak self] (image, customError) in
                
                DispatchQueue.main.async {
                    self?.competitionImageView.image = image
                }
            })
        }
    }
}
