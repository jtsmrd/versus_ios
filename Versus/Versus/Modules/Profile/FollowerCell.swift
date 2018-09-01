//
//  FollowerCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol FollowerCellDelegate {
    func followerCellFollowButtonActionError(error: CustomError)
    func followerCellFollowButtonActionUnfollow(follower: Follower)
}

class FollowerCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    weak var follower: Follower?
    var delegate: FollowerCellDelegate?
    var followStatus: FollowStatus {
        return CurrentUser.getFollowedUserStatusFor(userId: follower!.followerUserId)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = nil
        usernameLabel.text = nil
        displayNameLabel.text = nil
        follower = nil
        delegate = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    /**
     
     */
    @IBAction func followButtonAction() {
        CurrentUser.follow(
            follower: follower!
        ) { (customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.delegate?.followerCellFollowButtonActionError(error: customError)
                    return
                }
                self.followButton.setButtonState(followStatus: self.followStatus)
            }
        }
    }
    
    
    /**
     
     */
    func configureCell(follower: Follower, delegate: FollowerCellDelegate) {
        self.follower = follower
        self.delegate = delegate
        followButton.isHidden = CurrentUser.userIsMe(userId: follower.followerUserId)
        followButton.setButtonState(followStatus: followStatus)
        usernameLabel.text = follower.username
        displayNameLabel.text = follower.displayName
        follower.getProfileImage { (image, error) in
            DispatchQueue.main.async {
                if let image = image {
                    self.profileImageView.image = image
                }
            }
        }
    }
}
