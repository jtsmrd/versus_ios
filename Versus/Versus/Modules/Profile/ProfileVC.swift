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

class ProfileVC: UIViewController {

    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var followButton: RoundButton!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == nil {
            user = CurrentUser.user
        }
        
        rankContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showRanks)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }

    
    func initData(profileViewMode: ProfileViewMode, user: User) {
        self.profileViewMode = profileViewMode
        self.user = user
    }
    
    
    @IBAction func optionsButtonAction() {
        displayOptions()
    }
    
    @IBAction func directMessageButtonAction() {
        
    }
    
    @IBAction func closeButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func showRanks() {
        performSegue(withIdentifier: SHOW_RANKS, sender: nil)
    }
    
    private func configureView() {
        
        usernameLabel.text = "@\(user.awsUser._username!)"
        displayNameLabel.text = user.awsUser._displayName
        bioLabel.text = user.awsUser._bio
        winsLabel.text = "\(String(describing: user.awsUser._wins!))"
        rankImageView.image = UIImage(named: user.rank.imageName)
        rankLabel.text = user.rank.title
        profileImageView.image = user.profileImage
        backgroundImageView.image = user.profileBackgroundImage
        
        
        switch profileViewMode {
        case .edit:
            followButton.isHidden = true
            optionsButton.isHidden = false
            closeButton.isHidden = true
        case .viewOnly:
            followButton.isHidden = false
            optionsButton.isHidden = true
            closeButton.isHidden = false
        }
        
        // Get profile images
        if let userPoolUserId = user.awsUser._userPoolUserId {
            
            if let _ = user.awsUser._profileImageUpdateDate {
                UserService.instance.downloadImage(userPoolUserId: userPoolUserId, bucketType: .profileImage) { (image) in
                    if let image = image {
                        self.user.profileImage = image
                        DispatchQueue.main.async {
                            self.profileImageView.image = image
                        }
                    }
                }
            }
            
            if let _ = user.awsUser._profileBackgroundImageUpdateDate {
                UserService.instance.downloadImage(userPoolUserId: userPoolUserId, bucketType: .profileBackgroundImage) { (image) in
                    if let image = image {
                        self.user.profileBackgroundImage = image
                        DispatchQueue.main.async {
                            self.backgroundImageView.image = image
                        }
                    }
                }
            }
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
    }
}
