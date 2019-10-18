//
//  UserInfoView.swift
//  Versus
//
//  Created by JT Smrdel on 3/16/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import UIKit

protocol UserInfoViewDelegate {
    func follow()
    func unfollow()
    func viewWins()
    func viewRanks()
    func viewFollowedUsers()
    func viewFollowers()
    func viewEntries()
}

class UserInfoView: UICollectionReusableView {

    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var directMessageButton: UIButton!
    @IBOutlet weak var winsButton: UIButton!
    @IBOutlet weak var followButton: FollowButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followedUsersView: BorderView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersView: BorderView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var rankView: BorderView!
    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var rankTitleLabel: UILabel!
    @IBOutlet weak var entriesView: BorderView!
    @IBOutlet weak var entriesLabel: UILabel!
    
    @IBOutlet weak var entriesViewHeight: NSLayoutConstraint!
    
    private let s3BucketService = S3BucketService.instance
    
    private var originalEntriesViewHeight: CGFloat!
    private var followStatus: FollowStatus = .notFollowing
    private var delegate: UserInfoViewDelegate?
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        originalEntriesViewHeight = entriesViewHeight.constant
        
        followedUsersView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(CurrentUserInfoView.followedUsersTapped)
            )
        )
        
        followersView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(CurrentUserInfoView.followersTapped)
            )
        )
        
        rankView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(CurrentUserInfoView.rankTapped)
            )
        )
        
        entriesView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(CurrentUserInfoView.entriesViewTapped)
            )
        )
    }
    
    
    
    
    @IBAction func directMessageButtonAction() {
        
    }
    
    
    @IBAction func winsButtonAction() {
        delegate?.viewWins()
    }
    
    
    @IBAction func followButtonAction() {
        
        switch followStatus {
            
        case .following:
            delegate?.unfollow()
            
        case .notFollowing:
            delegate?.follow()
        }
    }
    
    
    @objc func rankTapped() {
        delegate?.viewRanks()
    }
    
    
    @objc func followedUsersTapped() {
        delegate?.viewFollowedUsers()
    }
    
    
    @objc func followersTapped() {
        delegate?.viewFollowers()
    }
    
    
    @objc func entriesViewTapped() {
        delegate?.viewEntries()
    }
    
    
    
    
    func configureView(
        user: User,
        entries: [Entry],
        delegate: UserInfoViewDelegate
    ) {
        
        self.delegate = delegate
        
        if CurrentAccount.userIsMe(userId: user.id) {
            followButton.isHidden = true
        }
        else {
            followStatus = CurrentAccount.getFollowStatusFor(userId: user.id)
            followButton.setButtonState(followStatus: followStatus)
        }
        
        displayNameLabel.text = user.name
        bioLabel.text = user.bio
        winsLabel.text = String(format: "%d", user.totalWins)
        
        followersLabel.attributedText = NSMutableAttributedString()
            .bold("\(user.followerCount)", self.followersLabel.font.pointSize)
            .normal(" followers")
        
        followingLabel.attributedText = NSMutableAttributedString()
            .bold("\(user.followedUserCount)", self.followingLabel.font.pointSize)
            .normal(" following")
        
        rankImageView.image = user.rank.image
        rankTitleLabel.text = user.rank.title
        
        
        configureEntriesView(entries: entries)
        downloadProfileImage(user: user)
        downloadBackgroundImage(user: user)
    }
    
    
    
    
    private func configureEntriesView(entries: [Entry]) {
        
        if entries.isEmpty {
            
            entriesViewHeight.constant = 1.0
        }
        else {
            
            entriesViewHeight.constant = originalEntriesViewHeight
            entriesLabel.text = String(
                format: "Unmatched Entries (%d)",
                entries.count
            )
        }
        layoutIfNeeded()
    }
    
    
    private func downloadProfileImage(user: User) {
        
        if !user.profileImage.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: user.profileImage,
                imageType: .regular
            ) { [weak self] (image, customError) in
                
                DispatchQueue.main.async {
                    
                    if customError != nil {
                        self?.parentViewController?.displayMessage(
                            message: "Unable to download profile image"
                        )
                        return
                    }
                    
                    self?.profileImageView.image = image
                }
            }
        }
    }
    
    
    private func downloadBackgroundImage(user: User) {
        
        if !user.backgroundImage.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: user.backgroundImage,
                imageType: .background
            ) { [weak self] (image, customError) in
                
                DispatchQueue.main.async {
                    
                    if customError != nil {
                        self?.parentViewController?.displayMessage(
                            message: "Unable to download background image"
                        )
                        return
                    }
                    
                    self?.backgroundImageView.image = image
                }
            }
        }
    }
}
