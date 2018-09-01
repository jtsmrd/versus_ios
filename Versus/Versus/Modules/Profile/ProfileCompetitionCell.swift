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
    
    
    /**
        Get and display the competition image for the current user.
     */
    func configureCell(competitionIndex: Int, user: User?) {
        guard let user = user else { return }
        let competition = user.competitions[competitionIndex]
        var currentUserCompetitorRecord: Competitor!
        if competition.firstCompetitor.userId == user.userId {
            currentUserCompetitorRecord = competition.firstCompetitor
        }
        else {
            currentUserCompetitorRecord = competition.secondCompetitor
        }
        DispatchQueue.global(qos: .userInitiated).async {
            currentUserCompetitorRecord.getCompetitionImageSmall(
                completion: { [weak self] (image, customError) in
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
