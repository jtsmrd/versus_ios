//
//  ProfileInfoVC.swift
//  Versus
//
//  Created by JT Smrdel on 2/29/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

protocol ProfileInfoVCDelegate: class {
    func userReloaded(user: User)
}

class ProfileInfoVC: UIViewController {

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
    
    
    private let userService = UserService.instance
    private let entryService = EntryService.instance
    private let followerService = FollowerService.instance
    private let s3BucketService = S3BucketService.instance
    private let notificationCenter = NotificationCenter.default
    
    
    private var user: User!
    private weak var delegate: ProfileInfoVCDelegate?
    private var viewMode: UserViewMode!
    private var entries = [Entry]()
    private var followStatus: FollowStatus = .notFollowing
    
    
    init(
        user: User,
        delegate: ProfileInfoVCDelegate?,
        viewMode: UserViewMode
    ) {
        super.init(nibName: nil, bundle: nil)
        
        self.user = user
        self.delegate = delegate
        self.viewMode = viewMode
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.addObserver(
            self,
            selector: #selector(ProfileInfoVC.reloadUser),
            name: NSNotification.Name.OnFollowersUpdated,
            object: nil
        )
        
        configureGestureRecognizers()
        
        configureView()
        
        loadUserData(shouldLoadEntries: true)
    }

    
    
    @IBAction func directMessageButtonAction() {
        
    }
    
    
    @IBAction func winsButtonAction() {
        viewWins()
    }
    
    
    @IBAction func followButtonAction() {
        
        switch followStatus {

        case .following:
            displayUnfollowAlert()

        case .notFollowing:
            
            followUser()
            
            // Manually set follow status to update UI immediately.
            // Revert if there's a failure
            followButton.setButtonState(followStatus: .following)
            followButton.isEnabled = false
        }
    }
    
    
    @objc func rankTapped() {
        viewRank()
    }
    
    
    @objc func followedUsersTapped() {
        viewFollowedUsers()
    }
    
    
    @objc func followersTapped() {
        viewFollowers()
    }
    
    
    @objc func entriesViewTapped() {
        viewEntries()
    }
    
    
    @objc func reloadUser() {
        loadUserData()
    }
    
    
    
    private func loadEntries() {
        
        entryService.loadEntries(
            userId: user.id
        ) { [weak self] (entries, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                if let error = error {
                    self.displayMessage(message: error)
                }
                
                self.entries = entries
                self.entriesLabel.text = String(
                    format: "Unmatched Entries (%d)",
                    entries.count
                )
            }
        }
    }
    
    
    private func configureGestureRecognizers() {
        
        followedUsersView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(ProfileInfoVC.followedUsersTapped)
            )
        )
        
        followersView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(ProfileInfoVC.followersTapped)
            )
        )
        
        rankView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(ProfileInfoVC.rankTapped)
            )
        )
        
        entriesView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(ProfileInfoVC.entriesViewTapped)
            )
        )
    }
    
    
    private func configureView() {
        
        displayNameLabel.text = user.name
        bioLabel.text = user.bio
        winsLabel.text = String(
            format: "%d",
            user.totalWins
        )
        
        followersLabel.attributedText = NSMutableAttributedString()
            .bold("\(user.followerCount)", self.followersLabel.font.pointSize)
            .normal(" followers")
        
        followingLabel.attributedText = NSMutableAttributedString()
            .bold("\(user.followedUserCount)", self.followingLabel.font.pointSize)
            .normal(" following")
        
        rankImageView.image = user.rank.image
        rankTitleLabel.text = user.rank.title
        
        configureFollowButton()
        
        downloadProfileImage()
        
        downloadBackgroundImage()
    }
    
    
    private func configureFollowButton() {
        
        switch viewMode {
            
        case .edit:
            
            followButton.isHidden = true
            
        case .readOnly:
            
            // ToDo: Create endpoint for this
            followStatus = CurrentAccount.getFollowStatusFor(
                userId: user.id
            )
            followButton.setButtonState(followStatus: followStatus)
            
        default:
            break
        }
    }
    
    
    private func downloadProfileImage() {
        
        if !user.profileImageId.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: user.profileImageId,
                imageType: .regular
            ) { [weak self] (image, error) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    
                    if let error = error {
                        debugPrint(error)
                    }
                    
                    self.profileImageView.image = image
                }
            }
        }
    }
    
    
    private func downloadBackgroundImage() {
        
        if !user.backgroundImage.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: user.backgroundImage,
                imageType: .background
            ) { [weak self] (image, error) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    
                    if let error = error {
                        debugPrint(error)
                    }
                    
                    self.backgroundImageView.image = image
                }
            }
        }
    }
    
    
    private func followUser() {
        
        followerService.followUser(
            userId: user.id
        ) { [weak self] (error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.followButton.isEnabled = true
                
                if let error = error {
                    self.displayMessage(message: error)
                    self.followButton.setButtonState(
                        followStatus: .notFollowing
                    )
                }
                else {
                    
                    CurrentAccount.addFollowedUserId(
                        id: self.user.id
                    )
                    
                    self.loadUserData()
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
            
            self.loadAndUnFollowUser()
            
            // Manually set follow status to update UI immediately.
            // Revert if there's a failure
            self.followButton.setButtonState(
                followStatus: .notFollowing
            )
            self.followButton.isEnabled = false
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        unfollowAlert.addAction(unfollowAction)
        unfollowAlert.addAction(cancelAction)
        
        present(
            unfollowAlert,
            animated: true,
            completion: nil
        )
    }
    
    
    // ToDo: Create new endpoint to delete the follower record by just
    // using the userId.
    private func loadAndUnFollowUser() {
        
        let userId = CurrentAccount.user.id
        
        followerService.getFollowedUser(
            userId: userId,
            followedUserId: user.id
        ) { [weak self] (follower, error) in
            guard let self = self else { return }
            
            if let error = error {
                
                DispatchQueue.main.async {
                    self.displayMessage(message: error)
                }
            }
            else if let follower = follower {
                
                self.unfollowUser(follower: follower)
            }
            else {
                
                DispatchQueue.main.async {
                    self.displayMessage(
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
                        self.displayMessage(message: error)
                        self.followButton.setButtonState(
                            followStatus: .following
                        )
                    }
                    else {
                        
                        CurrentAccount.removeFollowedUserId(
                            id: follower.id
                        )
                        
                        self.loadUserData()
                    }
                }
            }
        )
    }
    
    
    private func viewWins() {
        
    }
    
    
    private func viewRank() {
        
        let rankVC = RankVC(user: user)
        navigationController?.pushViewController(
            rankVC,
            animated: true
        )
    }
    
    
    private func viewFollowedUsers() {
        
        let followerVC = FollowerVC(
            userId: user.id,
            followerType: .followedUser
        )
        navigationController?.pushViewController(
            followerVC,
            animated: true
        )
    }
    
    
    private func viewFollowers() {
        
        let followerVC = FollowerVC(
            userId: user.id,
            followerType: .follower
        )
        navigationController?.pushViewController(
            followerVC,
            animated: true
        )
    }
    
    
    private func viewEntries() {
        
        let entriesVC = EntriesVC(entries: entries)
        navigationController?.pushViewController(
            entriesVC,
            animated: true
        )
    }
    
    
    // MARK: - Public functions
    
    func loadUserData(shouldLoadEntries: Bool = false) {
        
        userService.loadUser(
            userId: user.id
        ) { [weak self] (user, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                if let error = error {
                    self.displayMessage(message: error)
                }
                else if let user = user {
                    
                    self.user = user
                    self.delegate?.userReloaded(user: user)
                    self.configureView()
                    self.loadEntries()
                }
                else {
                    self.displayMessage(
                        message: "Unable to reload user."
                    )
                }
            }
        }
        
        if shouldLoadEntries {
            loadEntries()
        }
    }
}
