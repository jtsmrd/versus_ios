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
            imageName: comment.awsComment._userPoolUserId!,
            bucketType: .profileImageSmall
        ) { (image, error) in
            DispatchQueue.main.async {
                if let error = error {
                    debugPrint("Error loading profile image: \(error.localizedDescription)")
                }
                self.profileImageView.image = image
            }
        }
        
        usernameLabel.text = comment.awsComment._username!
        commentLabel.text = comment.awsComment._commentText
        commentTimeLabel.text = comment.awsComment._createDate?.toISO8601Date?.toElapsedTimeString_Minimal
    }
}
