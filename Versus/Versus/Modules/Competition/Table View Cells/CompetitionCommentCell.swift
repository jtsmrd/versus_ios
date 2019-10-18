//
//  CompetitionCommentCell.swift
//  Versus
//
//  Created by JT Smrdel on 7/28/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class CompetitionCommentCell: UITableViewCell {

    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentTimeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = nil
        usernameLabel.text = nil
        commentLabel.text = nil
        commentTimeLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func likeButtonAction() {
        
    }
    
    
    func configureCell(comment: Comment) {
        
        S3BucketService.instance.downloadImage(
            mediaId: comment.userId,
            imageType: .small
        ) { (image, errorMessage) in
            
            DispatchQueue.main.async {
                
                if let errorMessage = errorMessage {
                    debugPrint(errorMessage)
                    return
                }
                self.profileImageView.image = image
            }
        }
        
        usernameLabel.text = comment.username
        commentLabel.text = comment.message
        commentTimeLabel.text = comment.createDate.toElapsedTimeString_Minimal
    }
}
