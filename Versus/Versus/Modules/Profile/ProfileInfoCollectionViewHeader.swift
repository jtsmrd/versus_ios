//
//  ProfileInfoCollectionViewHeader.swift
//  Versus
//
//  Created by JT Smrdel on 5/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol ProfileInfoCollectionViewHeaderDelegate {
    func unfollowedUser(user: User)
}

class ProfileInfoCollectionViewHeader: UICollectionReusableView {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var directMessageButton: UIButton!
    @IBOutlet weak var winsButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followingContainerView: BorderView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersContainerView: BorderView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var rankContainerView: BorderView!
    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var rankTitleLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    
    private var user: User!
    private var followStatus: FollowStatus = .notFollowing
    private var delegate: ProfileInfoCollectionViewHeaderDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followingContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFollowing)))
        followersContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFollowers)))
        rankContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showRanks)))
    }
    
    @IBAction func directMessageButtonAction() {
        
    }
    
    
    @IBAction func winsButtonAction() {
        
    }
    
    
    @IBAction func followButtonAction() {
        switch followStatus {
        case .following:
            displayConfirmUnfollowUser()
        case .notFollowing:
            followUser()
        }
    }
    
    
    
    @objc func showRanks() {
        self.parentViewController?.performSegue(withIdentifier: SHOW_RANKS, sender: nil)
    }
    
    @objc func showFollowing() {
        self.parentViewController?.performSegue(withIdentifier: SHOW_FOLLOWERS, sender: FollowersViewType.following)
    }
    
    @objc func showFollowers() {
        self.parentViewController?.performSegue(withIdentifier: SHOW_FOLLOWERS, sender: FollowersViewType.follower)
    }
    
    
    
    func configureView(user: User, profileViewMode: ProfileViewMode, delegate: ProfileInfoCollectionViewHeaderDelegate) {
        
        self.user = user
        self.delegate = delegate
        
        // Only used when viewing other users' profiles
        if profileViewMode == .viewOnly {
            determineUserFollowStatus()
        }
        
        displayNameLabel.text = user.awsUser._displayName
        bioLabel.text = user.awsUser._bio
        winsLabel.text = "\(String(describing: user.awsUser._wins!))"
        
        // Get followers and update followers label count
        user.getFollowers { (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.parentViewController?.displayError(error: error)
                }
                else if success {
                    self.followersLabel.attributedText = NSMutableAttributedString()
                        .bold("\(user.followers.count)", self.followersLabel.font.pointSize)
                        .normal(" followers")
                }
            }
        }
        
        // Get followed users and update followed users label count
        user.getFollowedUsers { (followedUsers, customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.parentViewController?.displayError(error: customError)
                }
                else if let followedUsers = followedUsers {
                    self.followingLabel.attributedText = NSMutableAttributedString()
                        .bold("\(followedUsers.count)", self.followingLabel.font.pointSize)
                        .normal(" following")
                }
            }
        }
        
        rankImageView.image = UIImage(named: user.rank.imageName)
        rankTitleLabel.text = user.rank.title
        profileImageView.image = user.profileImage
        backgroundImageView.image = user.profileBackgroundImage
        
        switch profileViewMode {
        case .edit:
            followButton.isHidden = true
        case .viewOnly:
            
            if CurrentUser.userIsMe(user: user) {
                followButton.isHidden = true
            }
            else {
                followButton.isHidden = false
                configureFollowerButton()
            }
        }
        
        // Get profile image
        user.getProfileImage { (image) in
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
        }
        
        // Get background image
        user.getProfileBackgroundImage { (image) in
            DispatchQueue.main.async {
                self.backgroundImageView.image = image
            }
        }
    }
    
    
    
    private func determineUserFollowStatus() {
        followStatus = CurrentUser.followStatus(for: user)
    }
    
    
    private func configureFollowerButton() {
        followButton.setButtonState(followStatus: followStatus)
    }
    
    
    private func displayConfirmUnfollowUser() {
        let confirmUnfollowAlertVC = UIAlertController(title: "Confirm Unfollow", message: "Are you sure you want to unfollow @\(user.awsUser._username!)", preferredStyle: .actionSheet)
        confirmUnfollowAlertVC.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { (action) in
            self.unfollowUser()
        }))
        confirmUnfollowAlertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        self.parentViewController?.present(confirmUnfollowAlertVC, animated: true, completion: nil)
    }
    
    
    private func followUser() {
        FollowerService.instance.followUser(
            userToFollow: user,
            currentUser: CurrentUser.user
        ) { (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.parentViewController?.displayError(error: error)
                }
                else if success {
                    self.determineUserFollowStatus()
                    self.configureFollowerButton()
                }
            }
        }
    }
    
    
    private func unfollowUser() {
        if let follower = CurrentUser.getFollower(for: user) {
            FollowerService.instance.unfollowUser(
                followedUser: follower,
                currentUser: CurrentUser.user
            ) { (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.parentViewController?.displayError(error: error)
                    }
                    else if success {
                        self.determineUserFollowStatus()
                        self.configureFollowerButton()
                        self.delegate.unfollowedUser(user: self.user)
                    }
                }
            }
        }
        else {
            self.parentViewController?.displayError(error: CustomError(error: nil, title: "", desc: "Unable to unfollow user"))
        }
    }
}
