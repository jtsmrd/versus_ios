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
    
    
    
    
    func configureCell(entry: Entry) {
        
        competitionImageView.image = entry.image
    }
}
