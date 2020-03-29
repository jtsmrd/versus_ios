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
    @IBOutlet weak var followButton: FollowButton!
    
    
    private let followerService = FollowerService.instance
    private let s3BucketService = S3BucketService.instance
    
    
    private var userDisplayed: User!
    private var followStatus: FollowStatus = .notFollowing
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = nil
        usernameLabel.text = nil
        displayNameLabel.text = nil
    }
    
    
    
    
    @IBAction func followButtonAction() {
        
        switch followStatus {
            
        case .following:
            displayUnfollowAlert()
            
        case .notFollowing:
            
            followUser()
            
            // Manually set follow status to update UI immediately.
            // Revert if there's a failure
            followStatus = .following
            configureFollowButton()
            followButton.isEnabled = false
        }
    }
    
    
    
    private func configureFollowButton() {
        
        followButton.setButtonState(
            followStatus: followStatus
        )
    }
    
    
    private func followUser() {
                
        followerService.followUser(
            userId: userDisplayed.id
        ) { [weak self] (error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.followButton.isEnabled = true
                
                if let error = error {
                    self.parentViewController?.displayMessage(
                        message: error
                    )
                    self.followStatus = .notFollowing
                    self.configureFollowButton()
                }
                else {
                    CurrentAccount.addFollowedUserId(
                        id: self.userDisplayed.id
                    )
                }
            }
        }
    }
    
    
    private func displayUnfollowAlert() {
        
        let unfollowAlert = UIAlertController(
            title: "Confirm Unfollow",
            message: "Are you sure you want to unfollow @\(userDisplayed.username)",
            preferredStyle: .actionSheet
        )
        
        let unfollowAction = UIAlertAction(
            title: "Unfollow",
            style: .destructive
        ) { (action) in
                        
            self.loadFollowerRecord(
                userId: self.userDisplayed.id
            )
            
            // Manually set follow status to update UI immediately.
            // Revert if there's a failure
            self.followStatus = .notFollowing
            self.configureFollowButton()
            self.followButton.isEnabled = false
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        unfollowAlert.addAction(unfollowAction)
        unfollowAlert.addAction(cancelAction)
        
        parentViewController?.present(
            unfollowAlert,
            animated: true,
            completion: nil
        )
    }
    
    
    private func loadFollowerRecord(userId: Int) {
        
        followerService.getFollowedUser(
            userId: CurrentAccount.user.id,
            followedUserId: userId
        ) { [weak self] (follower, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.parentViewController?.displayMessage(
                        message: error
                    )
                }
                else if let follower = follower {
                    self.unfollowUser(followerId: follower.id)
                }
            }
        }
    }
    
    
    private func unfollowUser(followerId: Int) {
        
        followerService.unfollow(
            followerId: followerId,
            completion: { [weak self] (error) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    
                    self.followButton.isEnabled = true
                    
                    if let error = error {
                        
                        self.parentViewController?.displayMessage(
                            message: error
                        )
                        
                        self.followStatus = .following
                        self.configureFollowButton()
                    }
                    else {
                        
                        CurrentAccount.removeFollowedUserId(
                            id: self.userDisplayed.id
                        )
                    }
                }
            }
        )
    }
    
    
    
    
    /**
     
     */
    func configureCell(
        follower: Follower,
        followerType: FollowerType
    ) {
        
        switch followerType {
        case .follower:
            userDisplayed = follower.user
            
        case .followedUser:
            userDisplayed = follower.followedUser
        }
        
        if CurrentAccount.userIsMe(userId: userDisplayed.id) {
            followButton.isHidden = true
        }
        else {
            followStatus = CurrentAccount.getFollowStatusFor(
                userId: userDisplayed.id
            )
            configureFollowButton()
        }
        
        usernameLabel.text = userDisplayed.username
        displayNameLabel.text = userDisplayed.name
        
//        s3BucketService.downloadImage(
//            mediaId: userDisplayed.profileImageId,
//            imageType: .regular
//        ) { [weak self] (image, error) in
//            guard let self = self else { return }
//
//            DispatchQueue.main.async {
//                self.profileImageView.image = image
//            }
//        }
    }
}
