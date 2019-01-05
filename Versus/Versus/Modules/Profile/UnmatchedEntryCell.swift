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

    
    func configureCell(competitionEntry: API_CompetitionEntry) {
        
        let timeSince = competitionEntry.createDate.toISO8601Date?.toElapsedTimeString_Minimal
        submittedTimeLabel.text = String(format: "Submitted %@ ago", timeSince ?? "some time")
        
        let categoryType = CategoryType(rawValue: competitionEntry.categoryTypeId)
        let competitionType = CompetitionType(rawValue: competitionEntry.competitionTypeId)
        
        if let categoryType = categoryType, let category = CategoryCollection.instance.getCategory(categoryType: categoryType), let competitionType = competitionType {
            
            let competitionTypeString = competitionType == .image ? "image" : "video"
            categoryTypeLabel.text = String(format: "%@ %@ entry", category.title, competitionTypeString)
        }
        else {
            categoryTypeLabel.text = nil
        }
    }
}
