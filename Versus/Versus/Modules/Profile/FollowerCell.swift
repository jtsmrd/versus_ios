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
    
    var follower: Follower!
    var followStatus: FollowStatus = .notFollowing
    var delegate: FollowerCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(follower: Follower, delegate: FollowerCellDelegate) {
        self.follower = follower
        self.delegate = delegate
        
        determineFollowerFollowStatus()
        configureButton()
        
        var followerImageName = ""
        
        switch follower.followerType! {
        case .follower:
            usernameLabel.text = "@\(follower.awsFollower._followerUsername!)"
            displayNameLabel.text = follower.awsFollower._followerDisplayName
            followerImageName = follower.awsFollower._followerUserId!
        case .following:
            usernameLabel.text = "@\(follower.awsFollower._followedUserUsername!)"
            displayNameLabel.text = follower.awsFollower._followedUserDisplayName
            followerImageName = follower.awsFollower._followedUserId!
        }
        
        if follower.profileImageSmall == nil {
            
            S3BucketService.instance.downloadImage(
                imageName: followerImageName,
                bucketType: .profileImageSmall
            ) { (image, error) in
                if let error = error {
                    debugPrint("Could not load follower image: \(error.localizedDescription)")
                }
                else if let image = image {
                    self.follower.profileImageSmall = image
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        }
        else {
            profileImageView.image = follower.profileImageSmall
        }
    }
    
    @IBAction func followButtonAction() {
        switch followStatus {
        case .following:
            displayConfirmUnfollowFollower()
        case .notFollowing:
            followFollower()
        }
    }
    
    private func determineFollowerFollowStatus() {
        followStatus = CurrentUser.followStatus(for: follower)
    }
    
    // Configure button to display 'follow' for unfollowed users or 'following' for followed users
    private func configureButton() {
        followButton.setButtonState(followStatus: followStatus)
    }
    
    private func followFollower() {
        FollowerService.instance.followFollower(
            followerToFollow: follower,
            currentUser: CurrentUser.user
        ) { (success, error) in
            if let error = error {
                self.delegate.followerCellFollowButtonActionError(error: error)
            }
            else if success {
                self.determineFollowerFollowStatus()
                self.configureButton()
            }
        }
    }
    
    private func displayConfirmUnfollowFollower() {
        if let parentVC = parentViewController {
            
            var followerUsername = ""
            switch follower.followerType! {
            case .follower:
                followerUsername = follower.awsFollower._followerUsername!
            case .following:
                followerUsername = follower.awsFollower._followedUserUsername!
            }
            
            let confirmUnfollowAlertVC = UIAlertController(title: "Confirm Unfollow", message: "Are you sure you want to unfollow @\(followerUsername)", preferredStyle: .actionSheet)
            confirmUnfollowAlertVC.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { (action) in
                self.unfollowFollower()
            }))
            confirmUnfollowAlertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            parentVC.present(confirmUnfollowAlertVC, animated: true, completion: nil)
        }
    }
    
    private func unfollowFollower() {
        if let followedUser = CurrentUser.getFollower(for: follower) {
            FollowerService.instance.unfollowUser(
                followedUser: followedUser,
                currentUser: CurrentUser.user
            ) { (success, error) in
                if let error = error {
                    self.delegate.followerCellFollowButtonActionError(error: error)
                }
                else if success {
                    self.delegate.followerCellFollowButtonActionUnfollow(follower: self.follower)
                    self.determineFollowerFollowStatus()
                    self.configureButton()
                }
            }
        }
        else {
            delegate.followerCellFollowButtonActionError(error: CustomError(error: nil, title: "", desc: "Unable to unfollow user"))
        }
    }
}
