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
    
    func configureCell(competition: Competition) {

        if CurrentUser.userPoolUserId == competition.awsCompetition._user1userPoolUserId {
            switch competition.competitionType {
            case .image:
                competition.getUser1CompetitionImage { (image) in
                    DispatchQueue.main.async {
                        self.competitionImageView.image = competition.user1CompetitionImage
                    }
                }
            case .video:
                print()
            }
        }
        else if CurrentUser.userPoolUserId == competition.awsCompetition._user2userPoolUserId {
            
            switch competition.competitionType {
            case .image:
                competition.getUser2CompetitionImage { (image) in
                    DispatchQueue.main.async {
                        self.competitionImageView.image = competition.user2CompetitionImage
                    }
                }
            case .video:
                print()
            }
        }
    }
}
