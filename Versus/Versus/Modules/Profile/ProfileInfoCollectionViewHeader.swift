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
        
        followingContainerView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(showFollowedUsers)
            )
        )
        followersContainerView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(showFollowers)
            )
        )
        rankContainerView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(showRanks)
            )
        )
    }
    
    deinit {
        followingContainerView.gestureRecognizers?.removeAll()
        followersContainerView.gestureRecognizers?.removeAll()
        rankContainerView.gestureRecognizers?.removeAll()
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
    
    @objc func showFollowedUsers() {
        self.parentViewController?.performSegue(withIdentifier: SHOW_FOLLOWED_USERS, sender: nil)
    }
    
    @objc func showFollowers() {
        self.parentViewController?.performSegue(withIdentifier: SHOW_FOLLOWERS, sender: nil)
    }
    
    
    
    func configureView(user: User?, profileViewMode: ProfileViewMode, delegate: ProfileInfoCollectionViewHeaderDelegate) {
        guard let user = user else { return }
        self.user = user
        self.delegate = delegate
        
        // Only used when viewing other users' profiles
        if profileViewMode == .viewOnly {
            determineUserFollowStatus()
        }
        
        displayNameLabel.text = user.displayName
        bioLabel.text = user.bio
        winsLabel.text = String(format: "%d", user.totalWins)
        
        self.followersLabel.attributedText = NSMutableAttributedString()
            .bold("\(user.followerCount)", self.followersLabel.font.pointSize)
            .normal(" followers")
        
        self.followingLabel.attributedText = NSMutableAttributedString()
            .bold("\(user.followedUserCount)", self.followingLabel.font.pointSize)
            .normal(" following")
        
        rankImageView.image = UIImage(named: user.rank.imageName)
        rankTitleLabel.text = user.rank.title
        profileImageView.image = user.profileImage
        backgroundImageView.image = user.profileBackgroundImage
        
        switch profileViewMode {
        case .edit:
            followButton.isHidden = true
        case .viewOnly:
            
            if CurrentUser.userIsMe(userId: user.userId) {
                followButton.isHidden = true
            }
            else {
                followButton.isHidden = false
                configureFollowerButton()
            }
        }
        
        // Get profile image
        user.getProfileImage { (image, error) in
            DispatchQueue.main.async {
                if let image = image {
                    self.profileImageView.image = image
                }
            }
        }
        
        // Get background image
        user.getProfileBackgroundImage { (image, error) in
            DispatchQueue.main.async {
                if let image = image {
                    self.backgroundImageView.image = image
                }
            }
        }
    }
    
    
    
    private func determineUserFollowStatus() {
        followStatus = CurrentUser.getFollowedUserStatusFor(userId: user.userId)
    }
    
    
    private func configureFollowerButton() {
        followButton.setButtonState(followStatus: followStatus)
    }
    
    
    private func displayConfirmUnfollowUser() {
        let confirmUnfollowAlertVC = UIAlertController(
            title: "Confirm Unfollow",
            message: "Are you sure you want to unfollow @\(user.username)",
            preferredStyle: .actionSheet
        )
        confirmUnfollowAlertVC.addAction(
            UIAlertAction(
                title: "Unfollow",
                style: .destructive,
                handler: { (action) in
                    self.unfollowUser()
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
        self.parentViewController?.present(confirmUnfollowAlertVC, animated: true, completion: nil)
    }
    
    
    /**
     
     */
    private func followUser() {
        CurrentUser.follow(
            user: user
        ) { (customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.parentViewController?.displayError(error: customError)
                    return
                }
                self.determineUserFollowStatus()
                self.configureFollowerButton()
            }
        }
    }
    
    
    /**
 
     */
    private func unfollowUser() {
        CurrentUser.unfollow(
            user: user
        ) { (customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.parentViewController?.displayError(error: customError)
                    return
                }
                self.determineUserFollowStatus()
                self.configureFollowerButton()
                self.delegate.unfollowedUser(user: self.user)
            }
        }
    }
}
