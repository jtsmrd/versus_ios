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
    
    private var entry: Entry?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        competitionImageView.image = UIImage(named: "default-profile")
        entry = nil
    }
    
    func updateImage() {
        
        if let image = entry?.image {
            competitionImageView.image = image
        }
    }
    
    func configureCell(entry: Entry) {
        self.entry = entry
        
        if let image = entry.image {
            competitionImageView.image = image
        }
    }
}
