//
//  UnmatchedEntryCell.swift
//  Versus
//
//  Created by JT Smrdel on 1/4/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import UIKit

class UnmatchedEntryCell: UITableViewCell {

    
    @IBOutlet weak var submittedTimeLabel: UILabel!
    @IBOutlet weak var categoryTypeLabel: UILabel!
    @IBOutlet weak var competitionImageView: RoundedCornerImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        submittedTimeLabel.text = nil
        categoryTypeLabel.text = nil
        competitionImageView.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func configureCell(competitionEntry: CompetitionEntry) {
        
        let timeSince = competitionEntry.createDate.toElapsedTimeString_Minimal
        submittedTimeLabel.text = String(format: "Submitted %@ ago", timeSince)
        
        categoryTypeLabel.text = String(format: "%@ %@ entry", competitionEntry.category.title, competitionEntry.competitionTypeName)
    }
}
