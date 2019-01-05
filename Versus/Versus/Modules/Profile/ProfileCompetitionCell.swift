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
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            currentUserCompetitorRecord.getCompetitionImageSmall(completion: { [weak self] (image, customError) in
                
                    DispatchQueue.main.async {
                        
                        if let customError = customError {
                            self?.parentViewController?.displayError(error: customError)
                        }
                        self?.competitionImageView.image = image
                    }
                }
            )
        }
    }
}
