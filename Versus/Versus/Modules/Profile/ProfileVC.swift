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

class ProfileVC: UIViewController, ProfileInfoCollectionViewHeaderDelegate {
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var competitionCollectionView: UICollectionView!
    
    
    private var user: User!
    private var profileViewMode: ProfileViewMode = .edit
    
    
    var delegate: ProfileVCDelegate?
    let sectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == nil {
            user = CurrentUser.user
        }
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
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    func unfollowedUser(user: User) {
        delegate?.unfollowedUser(user: user)
    }
    
    
    private func configureView() {

        usernameLabel.text = "@\(user.awsUser._username!)"
        
        switch profileViewMode {
        case .edit:
            optionsButton.isHidden = false
            backButton.isHidden = true
        case .viewOnly:
            optionsButton.isHidden = true
            backButton.isHidden = false
        }

        // Get user's competitions
        user.getCompetitions { (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else {
                    self.competitionCollectionView.reloadData()
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
        if let editProfileVC = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: EDIT_PROFILE_VC) as? EditProfileVC {
            editProfileVC.initData(user: user)
            present(editProfileVC, animated: true, completion: nil)
        }
    }
    
    
    private func signOut() {
        AccountService.instance.signOut { (success) in
            if success {
                DispatchQueue.main.async {
                    if let loginVC = UIStoryboard(name: LOGIN, bundle: nil).instantiateInitialViewController() {
                        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = loginVC
                        (UIApplication.shared.delegate as! AppDelegate).window?.makeKeyAndVisible()
                    }
                }
            }
        }
    }
    
    
    private func showCompetition(competition: Competition) {
        
        if let viewCompetitionVC = UIStoryboard(name: COMPETITION, bundle: nil).instantiateInitialViewController() as? ViewCompetitionVC {
            viewCompetitionVC.initData(competition: competition)
            navigationController?.pushViewController(viewCompetitionVC, animated: true)
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

extension ProfileVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        return user.competitions.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PROFILE_COMPETITION_CELL,
            for: indexPath) as? ProfileCompetitionCell {
            cell.configureCell(competition: user.competitions[indexPath.row])
            return cell
        }
        return ProfileCompetitionCell()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
        if let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: PROFILE_INFO_COLLECTION_VIEW_HEADER,
            for: indexPath) as? ProfileInfoCollectionViewHeader {
            view.configureView(user: user, profileViewMode: profileViewMode, delegate: self)
            return view
        }
        return ProfileInfoCollectionViewHeader()
    }
}

extension ProfileVC: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath) {
        showCompetition(competition: user.competitions[indexPath.row])
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

extension ProfileVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemsPerRow: CGFloat = 3
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
    }
}
