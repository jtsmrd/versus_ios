//
//  FollowerCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class FollowerCell: UITableViewCell {

    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: RoundButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(user: User) {
        usernameLabel.text = user.awsUser._username
        displayNameLabel.text = user.awsUser._displayName
        
        if let _ = user.awsUser._profileImageUpdateDate {
            S3BucketService.instance.downloadImage(imageName: user.awsUser._userPoolUserId!, bucketType: .profileImageSmall) { (image, error) in
                if let error = error {
                    debugPrint("Could not load user profile image: \(error.localizedDescription)")
                }
                else if let image = image {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        }
    }
    
    @IBAction func followButtonAction() {
        
    }
}