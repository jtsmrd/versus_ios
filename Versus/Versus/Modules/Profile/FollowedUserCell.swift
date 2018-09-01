//
//  FollowedUserCell.swift
//  Versus
//
//  Created by JT Smrdel on 8/15/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol FollowedUserCellDelegate {
    func followedUserCellFollowButtonActionError(error: CustomError)
    func followedUserCellFollowButtonActionUnfollow(followedUser: FollowedUser)
}

class FollowedUserCell: UITableViewCell {

    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    weak var followedUser: FollowedUser?
    var delegate: FollowedUserCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = nil
        usernameLabel.text = nil
        displayNameLabel.text = nil
        followedUser = nil
        delegate = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    /**
 
     */
    @IBAction func unfollowButtonAction() {
        if let parentVC = parentViewController {
            let confirmUnfollowAlertVC = UIAlertController(
                title: "Confirm Unfollow",
                message: "Are you sure you want to unfollow @\(followedUser!.username)",
                preferredStyle: .actionSheet
            )
            confirmUnfollowAlertVC.addAction(
                UIAlertAction(
                    title: "Unfollow",
                    style: .destructive,
                    handler: { (action) in
                        self.unfollow()
                    }
                )
            )
            confirmUnfollowAlertVC.addAction(
                UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil
                )
            )
            parentVC.present(confirmUnfollowAlertVC, animated: true, completion: nil)
        }
    }
    
    
    /**
     
     */
    func configureCell(followedUser: FollowedUser, delegate: FollowedUserCellDelegate) {
        self.followedUser = followedUser
        self.delegate = delegate
        followButton.isHidden = CurrentUser.userIsMe(userId: followedUser.followedUserUserId)
        followButton.setButtonState(followStatus: .following)
        usernameLabel.text = followedUser.username
        displayNameLabel.text = followedUser.displayName
        followedUser.getProfileImage { (image, error) in
            DispatchQueue.main.async {
                if let image = image {
                    self.profileImageView.image = image
                }
            }
        }
    }
    
    
    /**
     
     */
    private func unfollow() {
        guard let followedUser = followedUser else { return }
        CurrentUser.unfollow(
            followedUser: followedUser
        ) { (customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.delegate?.followedUserCellFollowButtonActionError(error: customError)
                    return
                }
                self.delegate?.followedUserCellFollowButtonActionUnfollow(followedUser: followedUser)
            }
        }
    }
}
