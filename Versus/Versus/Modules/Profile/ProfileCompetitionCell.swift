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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        competitionImageView.image = nil
    }
    
    func configureCell(competition: Competition, user: User) {

        // We want to display the competition image for the current user,
        // so just check if the CurrentUser userPoolUserId matches user1 or user 2.
        let competitionUser: CompetitionUser = competition.awsCompetition._user1userPoolUserId! == user.awsUser._userPoolUserId! ? .user1 : .user2
        
        switch competition.competitionType {
        case .image:
            
            DispatchQueue.global(qos: .userInitiated).async {
                competition.getCompetitionImage(for: competitionUser, bucketType: .competitionImageSmall) { (image, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.parentViewController?.displayError(error: error)
                        }
                        else {
                            self.competitionImageView.image = image
                        }
                    }
                }
            }
            
        case .video:
            
            DispatchQueue.global(qos: .userInitiated).async {
                competition.getCompetitionImage(for: competitionUser, bucketType: .competitionVideoPreviewImageSmall) { (image, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.parentViewController?.displayError(error: error)
                        }
                        else {
                            self.competitionImageView.image = image
                        }
                    }
                }
            }            
        }
    }
}
