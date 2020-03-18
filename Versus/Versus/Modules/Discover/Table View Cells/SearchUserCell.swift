//
//  SearchUserCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/11/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    
    private let followerService = FollowerService.instance
    
    
    private var user: User!
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
    
    
    
    
    /**
     
     */
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
            userId: user.id
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
                        id: self.user.id
                    )
                }
            }
        }
    }
    
    
    private func displayUnfollowAlert() {
        
        let unfollowAlert = UIAlertController(
            title: "Confirm Unfollow",
            message: "Are you sure you want to unfollow @\(user.username)",
            preferredStyle: .actionSheet
        )
        
        let unfollowAction = UIAlertAction(
            title: "Unfollow",
            style: .destructive
        ) { (action) in
                        
            self.loadAndUnfollowUser()
            
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
    
    
    private func loadAndUnfollowUser() {
        
        let userId = CurrentAccount.user.id
        
        followerService.getFollowedUser(
            userId: userId,
            followedUserId: user.id
        ) { [weak self] (follower, error) in
            guard let self = self else { return }
            
            if let error = error {
                
                DispatchQueue.main.async {
                    
                    self.parentViewController?.displayMessage(
                        message: error
                    )
                }
            }
            else if let follower = follower {
                
                self.unfollowUser(follower: follower)
            }
            else {
                
                DispatchQueue.main.async {
                    
                    self.parentViewController?.displayMessage(
                        message: "Unable to unfollow user"
                    )
                }
            }
        }
    }
    
    
    private func unfollowUser(follower: Follower) {
        
        followerService.unfollow(
            followerId: follower.id,
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
                            id: follower.user.id
                        )
                    }
                }
            }
        )
    }
    
    
    /**
     
     */
    func configureCell(
        user: User,
        profileImage: UIImage?
    ) {
        self.user = user
        
        if CurrentAccount.userIsMe(userId: user.id) {
            followButton.isHidden = true
        }
        else {
            followStatus = CurrentAccount.getFollowStatusFor(
                userId: user.id
            )
            configureFollowButton()
        }
        
        usernameLabel.text = user.username
        displayNameLabel.text = user.name
        profileImageView.image = profileImage
    }
}
