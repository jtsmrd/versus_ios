//
//  ProfileVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/3/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class ProfileVC: UIViewController {

    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircleImageView!
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
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rankContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showRanks)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadUser()
    }

    
    @IBAction func optionsButtonAction() {
        displayOptions()
    }
    
    @IBAction func directMessageButtonAction() {
        
    }
    
    
    @objc func showRanks() {
        performSegue(withIdentifier: SHOW_RANKS, sender: nil)
    }
    
    
    private func loadUser() {
        
        UserService.instance.loadUser { (user) in
            if let user = user {
                self.user = user
                CurrentUser.user = user
                DispatchQueue.main.async {
                    self.configureView()
                }
            }
        }
    }
    
    private func configureView() {
        
        usernameLabel.text = user._username
        bioLabel.text = user._bio
        winsLabel.text = "\(String(describing: user._wins!))"
        rankImageView.image = UIImage(named: CurrentUser.rank.imageName)
        rankLabel.text = CurrentUser.rank.title
        profileImageView.image = CurrentUser.profileImage
        backgroundImageView.image = CurrentUser.profileBackgroundImage
        
        // Get profile images
        if let username = AWSCognitoIdentityUserPool.default().currentUser()?.username {
            
            if let _ = user._profileImageUpdateDate, CurrentUser.profileImage == nil {
                S3BucketService.instance.downloadImage(imageName: username, bucketType: .profileImage) { (image, error) in
                    if let error = error {
                        debugPrint("Error downloading profile image in edit profile: \(error.localizedDescription)")
                    }
                    else if let image = image {
                        CurrentUser.profileImage = image
                        DispatchQueue.main.async {
                            self.profileImageView.image = image
                        }
                    }
                }
            }
            
            if let _ = user._profileBackgroundImageUpdateDate, CurrentUser.profileBackgroundImage == nil {
                S3BucketService.instance.downloadImage(imageName: username, bucketType: .profileBackgroundImage) { (image, error) in
                    if let error = error {
                        debugPrint("Error downloading profile image in edit profile: \(error.localizedDescription)")
                    }
                    else if let image = image {
                        CurrentUser.profileBackgroundImage = image
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
        
    }
}
