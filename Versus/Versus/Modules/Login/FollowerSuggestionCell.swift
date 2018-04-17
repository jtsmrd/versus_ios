//
//  FollowerSuggestionCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/17/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol FollowerSuggestionCellDelegate {
    func followerSuggestionCellFollowButtonActionError(error: CustomError)
}

class FollowerSuggestionCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    var user: User!
    var followStatus: FollowStatus = .notFollowing
    var delegate: FollowerSuggestionCellDelegate!
    
    
    @IBAction func followButtonAction() {
        switch followStatus {
        case .following:
            displayConfirmUnfollowUser()
        case .notFollowing:
            followUser()
        }
    }
    
    
    func configureCell(user: User, delegate: FollowerSuggestionCellDelegate) {
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
                self.delegate.followerSuggestionCellFollowButtonActionError(error: error)
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
                    self.delegate.followerSuggestionCellFollowButtonActionError(error: error)
                }
                else if success {
                    self.determineUserFollowStatus()
                    self.configureFollowerButton()
                }
            }
        }
        else {
            delegate.followerSuggestionCellFollowButtonActionError(error: CustomError(error: nil, title: "", desc: "Unable to unfollow user"))
        }
    }
}
