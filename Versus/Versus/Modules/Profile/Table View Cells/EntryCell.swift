//
//  EntryCell.swift
//  Versus
//
//  Created by JT Smrdel on 1/4/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import UIKit

class EntryCell: UITableViewCell {

    
    @IBOutlet weak var submittedTimeLabel: UILabel!
    @IBOutlet weak var categoryTypeLabel: UILabel!
    @IBOutlet weak var entryImageView: RoundedCornerImageView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        submittedTimeLabel.text = nil
        categoryTypeLabel.text = nil
        entryImageView.image = nil
    }

    
    
    
    func configureCell(
        entry: Entry,
        entryImage: UIImage?
    ) {
        
        let timeSince = entry.createDate.toElapsedTimeString_Minimal
        submittedTimeLabel.text = String(
            format: "Submitted %@ ago",
            timeSince
        )
        
        categoryTypeLabel.text = String(
            format: "%@ %@ entry",
            entry.category.title,
            entry.competitionTypeName
        )
        
        entryImageView.image = entryImage
    }
}
