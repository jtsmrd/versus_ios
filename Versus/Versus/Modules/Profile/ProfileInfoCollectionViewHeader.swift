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
    @IBOutlet weak var followButton: FollowButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followingView: BorderView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersView: BorderView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var rankView: BorderView!
    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var rankTitleLabel: UILabel!
    @IBOutlet weak var unmatchedCompetitionEntriesView: BorderView!
    @IBOutlet weak var unmatchedCompetitionEntriesLabel: UILabel!
    
    @IBOutlet weak var unmatchedCompetitionEntriesViewHeight: NSLayoutConstraint!
    
    private let s3BucketService = S3BucketService.instance
    
    private var user: User!
    private var unmatchedEntries: [Entry]!
    private var originalUnmatchedCompetitionEntriesViewHeight: CGFloat!
    private var profileViewMode: ProfileViewMode = .viewOnly
    private var followStatus: FollowStatus = .notFollowing
    private var delegate: ProfileInfoCollectionViewHeaderDelegate!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        unmatchedEntries = [Entry]()
        
        originalUnmatchedCompetitionEntriesViewHeight = unmatchedCompetitionEntriesViewHeight.constant
        
        followingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileInfoCollectionViewHeader.showFollowedUsers)))
        
        followersView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileInfoCollectionViewHeader.showFollowers)))
        
        rankView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileInfoCollectionViewHeader.showRanks)))
        
        unmatchedCompetitionEntriesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileInfoCollectionViewHeader.unmatchedCompetitionEntriesViewTapped)))
    }
    
    
    deinit {
        followingView.gestureRecognizers?.removeAll()
        followersView.gestureRecognizers?.removeAll()
        rankView.gestureRecognizers?.removeAll()
        unmatchedCompetitionEntriesView.gestureRecognizers?.removeAll()
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
        parentViewController?.performSegue(withIdentifier: SHOW_RANKS, sender: nil)
    }
    
    
    @objc func showFollowedUsers() {
        parentViewController?.performSegue(withIdentifier: SHOW_FOLLOWED_USERS, sender: nil)
    }
    
    
    @objc func showFollowers() {
        parentViewController?.performSegue(withIdentifier: SHOW_FOLLOWERS, sender: nil)
    }
    
    
    @objc func unmatchedCompetitionEntriesViewTapped() {
        parentViewController?.performSegue(withIdentifier: SHOW_UNMATCHED_ENTRIES, sender: unmatchedEntries)
    }
    
    
    
    func configureView(
        user: User,
        profileViewMode: ProfileViewMode,
        unmatchedEntries: [Entry],
        delegate: ProfileInfoCollectionViewHeaderDelegate
    ) {
        
        self.user = user
        self.profileViewMode = profileViewMode
        self.unmatchedEntries = unmatchedEntries
        self.delegate = delegate
        
        //TEMPORARY: Hide direct message button until implemented.
        directMessageButton.isHidden = true
        
        displayNameLabel.text = user.name
        bioLabel.text = user.bio
        winsLabel.text = String(format: "%d", user.totalWins)
        
        followersLabel.attributedText = NSMutableAttributedString()
            .bold("\(user.followerCount)", self.followersLabel.font.pointSize)
            .normal(" followers")
        
        followingLabel.attributedText = NSMutableAttributedString()
            .bold("\(user.followedUserCount)", self.followingLabel.font.pointSize)
            .normal(" following")
        
        rankImageView.image = UIImage(named: user.rank.imageName)
        rankTitleLabel.text = user.rank.title
        
        configureFollowerButton()
        
        configureUnmatchedEntriesView()
        
        
        let profileImageId = CurrentAccount.user.profileImage
        if !profileImageId.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: profileImageId,
                imageType: .regular
            ) { [weak self] (image, customError) in
                
                if let customError = customError {
                    self?.parentViewController?.displayError(error: customError)
                    return
                }
                
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            }
        }
        
        let backgroundImage = CurrentAccount.user.backgroundImage
        if !backgroundImage.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: backgroundImage,
                imageType: .background
            ) { [weak self] (image, customError) in
                
                if let customError = customError {
                    self?.parentViewController?.displayError(error: customError)
                    return
                }
                
                DispatchQueue.main.async {
                    self?.backgroundImageView.image = image
                }
            }
        }
    }
    
    
    private func configureFollowerButton() {
        
        guard !CurrentAccount.userIsMe(userId: user.id) else {
            followButton.isHidden = true
            return
        }
        
        // See if you're following them or now.
        //TODO
//        followStatus = CurrentUser.getFollowedUserStatusFor(userId: user.userId)
        
        // Set the state of the button based on the followStatus.
        followButton.setButtonState(followStatus: followStatus)
    }
    
    
    private func configureUnmatchedEntriesView() {

        if CurrentAccount.userIsMe(userId: user.id) && unmatchedEntries.count > 0 {

            unmatchedCompetitionEntriesViewHeight.constant = originalUnmatchedCompetitionEntriesViewHeight
            unmatchedCompetitionEntriesLabel.text = String(format: "Unmatched Entries (%d)", unmatchedEntries.count)
        }
        else {
            unmatchedCompetitionEntriesViewHeight.constant = 1.0
        }
        
        layoutIfNeeded()
    }
    
    
    private func displayConfirmUnfollowUser() {
        
        let confirmUnfollowAlertVC = UIAlertController(title: "Confirm Unfollow", message: "Are you sure you want to unfollow @\(user.username)", preferredStyle: .actionSheet)
        
        let unfollowAction = UIAlertAction(title: "Unfollow", style: .destructive) { (action) in
            self.unfollowUser()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        confirmUnfollowAlertVC.addAction(unfollowAction)
        confirmUnfollowAlertVC.addAction(cancelAction)
        
        parentViewController?.present(confirmUnfollowAlertVC, animated: true, completion: nil)
    }
    
    
    /**
     
     */
    private func followUser() {
        //TODO
//        CurrentUser.follow(
//            user: user
//        ) { (customError) in
//
//            DispatchQueue.main.async {
//
//                if let customError = customError {
//                    self.parentViewController?.displayError(error: customError)
//                    return
//                }
//
//                self.configureFollowerButton()
//            }
//        }
    }
    
    
    /**
 
     */
    private func unfollowUser() {
        //TODO
//        CurrentUser.unfollow(
//            user: user
//        ) { (customError) in
//
//            DispatchQueue.main.async {
//
//                if let customError = customError {
//                    self.parentViewController?.displayError(error: customError)
//                    return
//                }
//
//                self.configureFollowerButton()
//                self.delegate.unfollowedUser(user: self.user)
//            }
//        }
    }
}
