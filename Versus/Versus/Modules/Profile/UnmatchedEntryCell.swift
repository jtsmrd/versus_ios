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
    
    let s3BucketService = S3BucketService.instance
    
    
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

    
    func configureCell(entry: Entry) {
        
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
        
        s3BucketService.downloadImage(
            mediaId: entry.mediaId,
            imageType: .regular
        ) { [weak self] (image, customError) in
            
            DispatchQueue.main.async {
                self?.competitionImageView.image = image
            }
        }
    }
}
