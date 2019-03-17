//
//  CurrentUserInfoView.swift
//  Versus
//
//  Created by JT Smrdel on 3/16/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import UIKit

protocol CurrentUserInfoViewDelegate {
    
    func viewWins()
    func viewRanks()
    func viewFollowedUsers()
    func viewFollowers()
    func viewEntries()
    func errorOccurred(errorMessage: String)
}

class CurrentUserInfoView: UICollectionReusableView {

    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var winsButton: UIButton!
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
    
    private var user: User!
    private var entries: [Entry]!
    private var originalEntriesViewHeight: CGFloat!
    private var delegate: CurrentUserInfoViewDelegate!
    
    
    
    
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
    
    
    
    @IBAction func winsButtonAction() {
        delegate.viewWins()
    }
    
    
    @objc func rankTapped() {
        delegate.viewRanks()
    }
    
    
    @objc func followedUsersTapped() {
        delegate.viewFollowedUsers()
    }
    
    
    @objc func followersTapped() {
        delegate.viewFollowers()
    }
    
    
    @objc func entriesViewTapped() {
        delegate.viewEntries()
    }
    
    
    
    func configureView(
        user: User,
        entries: [Entry],
        delegate: CurrentUserInfoViewDelegate
    ) {
        
        self.user = user
        self.entries = entries
        self.delegate = delegate
        
        
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
        
        
        configureEntriesView()
        downloadProfileImage()
        downloadBackgroundImage()
    }
    
    
    private func configureEntriesView() {
        
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
    
    
    
    private func downloadProfileImage() {
        
        if !user.profileImage.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: user.profileImage,
                imageType: .regular
            ) { [weak self] (image, customError) in
                
                if customError != nil {
                    self?.delegate.errorOccurred(
                        errorMessage: "Unable to download profile image"
                    )
                    return
                }
                
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            }
        }
    }
    
    
    
    private func downloadBackgroundImage() {
        
        if !user.backgroundImage.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: user.backgroundImage,
                imageType: .background
            ) { [weak self] (image, customError) in
                
                if customError != nil {
                    self?.delegate.errorOccurred(
                        errorMessage: "Unable to download background image"
                    )
                    return
                }
                
                DispatchQueue.main.async {
                    self?.backgroundImageView.image = image
                }
            }
        }
    }
}
