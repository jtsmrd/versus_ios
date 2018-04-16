//
//  ProfileVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/3/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

enum ProfileViewMode {
    case edit
    case viewOnly
}

protocol ProfileVCDelegate {
    func unfollowedUser(user: User)
}

class ProfileVC: UIViewController {
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var followButton: FollowButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followingContainerView: BorderView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersContainerView: BorderView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var rankContainerView: BorderView!
    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var competitionCollectionView: UICollectionView!
    
    private var user: User!
    private var profileViewMode: ProfileViewMode = .edit
    private var followStatus: FollowStatus = .notFollowing
    
    var delegate: ProfileVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == nil {
            user = CurrentUser.user
        }
        
        // Only used when viewing other users' profiles
        if profileViewMode == .viewOnly {
            determineUserFollowStatus()
        }
        
        followingContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFollowing)))
        followersContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFollowers)))
        rankContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showRanks)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if user.followers.count == 0 {
            user.getFollowers { (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.displayError(error: error)
                    }
                    else if success {
                        self.configureView()
                    }
                }
            }
        }
        
        if user.followedUsers.count == 0 {
            user.getFollowedUsers { (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.displayError(error: error)
                    }
                    else if success {
                        self.configureView()
                    }
                }
            }
        }
        
        configureView()
    }

    
    func initData(profileViewMode: ProfileViewMode, user: User) {
        self.profileViewMode = profileViewMode
        self.user = user
    }
    
    
    @IBAction func optionsButtonAction() {
        displayOptions()
    }
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func directMessageButtonAction() {
        
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
        performSegue(withIdentifier: SHOW_RANKS, sender: nil)
    }
    
    @objc func showFollowing() {
        performSegue(withIdentifier: SHOW_FOLLOWERS, sender: FollowersViewType.following)
    }
    
    @objc func showFollowers() {
        performSegue(withIdentifier: SHOW_FOLLOWERS, sender: FollowersViewType.follower)
    }
    
    
    
    private func configureView() {
        
        usernameLabel.text = "@\(user.awsUser._username!)"
        displayNameLabel.text = user.awsUser._displayName
        bioLabel.text = user.awsUser._bio
        winsLabel.text = "\(String(describing: user.awsUser._wins!))"
        
        followersLabel.attributedText = NSMutableAttributedString()
            .bold("\(user.followers.count)", followersLabel.font.pointSize)
            .normal(" followers")
        
        followingLabel.attributedText = NSMutableAttributedString()
            .bold("\(user.followedUsers.count)", followingLabel.font.pointSize)
            .normal(" following")
        
        rankImageView.image = UIImage(named: user.rank.imageName)
        rankLabel.text = user.rank.title
        profileImageView.image = user.profileImage
        backgroundImageView.image = user.profileBackgroundImage
        
        
        switch profileViewMode {
        case .edit:
            followButton.isHidden = true
            optionsButton.isHidden = false
            backButton.isHidden = true
        case .viewOnly:
            optionsButton.isHidden = true
            backButton.isHidden = false
            
            if CurrentUser.userIsMe(user: user) {
                followButton.isHidden = true
            }
            else {
                followButton.isHidden = false
                configureFollowerButton()
            }
        }
        
        // Get profile image
        if let _ = user.awsUser._profileImageUpdateDate, user.profileImage == nil {
            UserService.instance.downloadImage(
                userPoolUserId: user.awsUser._userPoolUserId!,
                bucketType: .profileImage
            ) { (image) in
                if let image = image {
                    self.user.profileImage = image
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        }
        
        // Get background image
        if let _ = user.awsUser._profileBackgroundImageUpdateDate, user.profileBackgroundImage == nil {
            UserService.instance.downloadImage(
                userPoolUserId: user.awsUser._userPoolUserId!,
                bucketType: .profileBackgroundImage
            ) { (image) in
                if let image = image {
                    self.user.profileBackgroundImage = image
                    DispatchQueue.main.async {
                        self.backgroundImageView.image = image
                    }
                }
            }
        }
    }
    
    
    private func determineUserFollowStatus() {
        followStatus = CurrentUser.followStatus(for: user)
    }
    
    
    private func configureFollowerButton() {
        followButton.setButtonState(followStatus: followStatus)
    }
    
    
    private func followUser() {
        FollowerService.instance.followUser(
            userToFollow: user,
            currentUser: CurrentUser.user
        ) { (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else if success {
                    self.determineUserFollowStatus()
                    self.configureFollowerButton()
                }
            }
        }
    }
    
    
    private func displayConfirmUnfollowUser() {
        let confirmUnfollowAlertVC = UIAlertController(title: "Confirm Unfollow", message: "Are you sure you want to unfollow @\(user.awsUser._username!)", preferredStyle: .actionSheet)
        confirmUnfollowAlertVC.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { (action) in
            self.unfollowUser()
        }))
        confirmUnfollowAlertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        present(confirmUnfollowAlertVC, animated: true, completion: nil)
    }
    
    
    private func unfollowUser() {
        if let follower = CurrentUser.getFollower(for: user) {
            FollowerService.instance.unfollowUser(
                followedUser: follower,
                currentUser: CurrentUser.user
            ) { (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.displayError(error: error)
                    }
                    else if success {
                        self.determineUserFollowStatus()
                        self.configureFollowerButton()
                        self.delegate?.unfollowedUser(user: self.user)
                    }
                }
            }
        }
        else {
            displayError(error: CustomError(error: nil, title: "", desc: "Unable to unfollow user"))
        }
    }
    
    
    private func displayOptions() {
        let optionsAlertController = UIAlertController(title: "Profile Options", message: nil, preferredStyle: .actionSheet)
        optionsAlertController.addAction(UIAlertAction(title: "Edit Profile", style: .default, handler: { (action) in
            self.displayEditProfile()
        }))
        
        optionsAlertController.addAction(UIAlertAction(title: "Change Password", style: .default, handler: { (action) in
            
        }))
        
        optionsAlertController.addAction(UIAlertAction(title: "Sign Out", style: .default, handler: { (action) in
            self.signOut()
        }))
        
        optionsAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        present(optionsAlertController, animated: true, completion: nil)
    }
    
    private func displayEditProfile() {
        if let editProfileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileVC {
            editProfileVC.initData(user: user)
            present(editProfileVC, animated: true, completion: nil)
        }
    }
    
    private func signOut() {
        AccountService.instance.signOut { (success) in
            if success {
                DispatchQueue.main.async {
                    if let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() {
                        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = loginVC
                        (UIApplication.shared.delegate as! AppDelegate).window?.makeKeyAndVisible()
                    }
                }
            }
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let rankVC = segue.destination as? RankVC {
            rankVC.initData(user: user)
        }
        else if let followerVC = segue.destination as? FollowerVC, let followersViewType = sender as? FollowersViewType {
            let followersViewMode: FollowersViewMode = profileViewMode == .edit ? .edit : .viewOnly
            let followers = followersViewType == .follower ? user.followers : user.followedUsers
            followerVC.initData(followersViewType: followersViewType, followerViewMode: followersViewMode, followers: followers)
        }
    }
}
