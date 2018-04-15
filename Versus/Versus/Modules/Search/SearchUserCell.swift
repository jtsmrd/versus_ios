//
//  SearchUserCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/11/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol SearchUserCellDelegate {
    func searchUserCellFollowButtonActionError(error: CustomError)
}

class SearchUserCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    var user: User!
    var followStatus: FollowStatus = .notFollowing
    var delegate: SearchUserCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(user: User, delegate: SearchUserCellDelegate) {
        self.user = user
        self.delegate = delegate
        
        determineUserFollowStatus()
        configureFollowerButton()
        
        usernameLabel.text = "@\(user.awsUser._username!)"
        displayNameLabel.text = user.awsUser._displayName
        
        if let _ = user.awsUser._profileImageUpdateDate, user.profileImage == nil {
            S3BucketService.instance.downloadImage(imageName: user.awsUser._userPoolUserId!, bucketType: .profileImageSmall) { (image, error) in
                if let error = error {
                    debugPrint("Could not load user profile image: \(error.localizedDescription)")
                }
                else if let image = image {
                    self.user.profileImage = image
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        }
    }
    
    @IBAction func followButtonAction() {
        switch followStatus {
        case .following:
            displayConfirmUnfollowUser()
        case .notFollowing:
            followUser()
        }
    }
    
    private func determineUserFollowStatus() {
        followStatus = CurrentUser.followStatus(for: user)
    }
    
    // Configure button to display 'follow' for unfollowed users or 'following' for followed users
    private func configureFollowerButton() {
        followButton.setButtonState(followStatus: followStatus)
    }
    
    private func followUser() {
        FollowerService.instance.followUser(
            userToFollow: user,
            currentUser: CurrentUser.user
        ) { (success, error) in
            if let error = error {
                self.delegate.searchUserCellFollowButtonActionError(error: error)
            }
            else if success {
                self.determineUserFollowStatus()
                self.configureFollowerButton()
            }
        }
    }
    
    private func displayConfirmUnfollowUser() {
        if let parentVC = parentViewController {
            let confirmUnfollowAlertVC = UIAlertController(title: "Confirm Unfollow", message: "Are you sure you want to unfollow @\(user.awsUser._username!)", preferredStyle: .actionSheet)
            confirmUnfollowAlertVC.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { (action) in
                self.unfollowUser()
            }))
            confirmUnfollowAlertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            parentVC.present(confirmUnfollowAlertVC, animated: true, completion: nil)
        }
    }
    
    private func unfollowUser() {
        if let follower = CurrentUser.getFollower(for: user) {
            FollowerService.instance.unfollowUser(
                followedUser: follower,
                currentUser: CurrentUser.user
            ) { (success, error) in
                if let error = error {
                    self.delegate.searchUserCellFollowButtonActionError(error: error)
                }
                else if success {
                    self.determineUserFollowStatus()
                    self.configureFollowerButton()
                }
            }
        }
        else {
            delegate.searchUserCellFollowButtonActionError(error: CustomError(error: nil, title: "", desc: "Unable to unfollow user"))
        }
    }
}
