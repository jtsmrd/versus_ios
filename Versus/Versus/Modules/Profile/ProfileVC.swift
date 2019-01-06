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
    @IBOutlet weak var competitionCollectionView: UICollectionView!
    
    private let userService = UserService.instance
    private let accountService = AccountService.instance
    private let competitionEntryService = CompetitionEntryService.instance
    private let competitionService = CompetitionService.instance
    
    private var userId: String!
    private var user: User?
    private var competitions: [Competition]!
    private var unmatchedCompetitionEntries: [CompetitionEntry]!
    private var profileViewMode: ProfileViewMode = .viewOnly
    
    var delegate: ProfileVCDelegate?
    let collectionViewSectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        competitions = [Competition]()
        unmatchedCompetitionEntries = [CompetitionEntry]()
        
        loadUser(userId: userId)
        
        loadCompetitions(userId: userId)
        
        loadUnmatchedCompetitionEntries(userId: userId)
    }

    
    
    func initData(userId: String, profileViewMode: ProfileViewMode) {
        self.userId = userId
        self.profileViewMode = profileViewMode
    }
    
    
    
    @IBAction func optionsButtonAction() {
        displayOptions()
    }
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    private func loadUser(userId: String) {
        
        userService.getUser(userId: userId) { [weak self] (awsUser, customError) in
            
            DispatchQueue.main.async {
                
                if let customError = customError {
                    self?.displayError(error: customError)
                    return
                }
                
                guard let awsUser = awsUser else {
                    self?.displayError(error: CustomError(error: nil, message: "Unable to load user"))
                    return
                }
                
                self?.user = User(awsUser: awsUser)
                self?.configureView()
            }
        }
    }
    
    
    private func loadCompetitions(userId: String) {
        
        competitionService.getCompetitionsFor(userId: userId) { [weak self] (competitions, customError) in
            
            DispatchQueue.main.async {
                
                if let customError = customError {
                    self?.displayError(error: customError)
                    return
                }
                
                self?.competitions = competitions                
                self?.competitionCollectionView.reloadData()
            }
        }
    }
    
    
    private func loadUnmatchedCompetitionEntries(userId: String) {
        
        competitionEntryService.getUnmatchedCompetitionEntries(
            userId: CurrentUser.userId
        ) { [weak self] (unmatchedCompetitionEntries, customError) in
            
            DispatchQueue.main.async {
                
                if let customError = customError {
                    self?.displayError(error: customError)
                    return
                }
                
                self?.unmatchedCompetitionEntries = unmatchedCompetitionEntries
                self?.competitionCollectionView.reloadData()
            }
        }
    }
    
    
    private func configureView() {
        
        usernameLabel.text = String(format: "@%@", user?.username ?? "")
        
        switch profileViewMode {
        case .edit:
            
            optionsButton.isHidden = false
            backButton.isHidden = true
            
        case .viewOnly:
            
            optionsButton.isHidden = true
            backButton.isHidden = false
        }
    }
    
    
    private func displayOptions() {
        
        let optionsAlertController = UIAlertController(title: "Profile Options", message: nil, preferredStyle: .actionSheet)
        
        let editProfileAction = UIAlertAction(title: "Edit Profile", style: .default) { (action) in
            self.displayEditProfile()
        }
        
        let changePasswordAction = UIAlertAction(title: "Change Password", style: .default) { (action) in
            
        }
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .default) { (action) in
            self.signOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionsAlertController.addAction(editProfileAction)
        optionsAlertController.addAction(changePasswordAction)
        optionsAlertController.addAction(signOutAction)
        optionsAlertController.addAction(cancelAction)
        
        present(optionsAlertController, animated: true, completion: nil)
    }
    
    
    private func displayEditProfile() {
        
        let mainStoryboard = UIStoryboard(name: MAIN, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: EDIT_PROFILE_VC)
        
        if let editProfileVC = viewController as? EditProfileVC {
            present(editProfileVC, animated: true, completion: nil)
        }
    }
    
    
    private func signOut() {
        
        accountService.signOut { (success) in
            
            if success {
                
                let loginStoryboard = UIStoryboard(name: LOGIN, bundle: nil)
                let loginNavController = loginStoryboard.instantiateInitialViewController()
                
                DispatchQueue.main.async {
                    
                    appDelegate.window?.rootViewController = loginNavController
                    appDelegate.window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    
    private func showCompetition(competition: Competition) {
        
        let competitionStoryboard = UIStoryboard(name: COMPETITION, bundle: nil)
        let viewController = competitionStoryboard.instantiateInitialViewController()
        
        if let viewCompetitionVC = viewController as? ViewCompetitionVC {
            
            viewCompetitionVC.initData(competition: competition)
            navigationController?.pushViewController(viewCompetitionVC, animated: true)
        }
    }
    

    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return user != nil
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let user = user else { return }
        
        if let rankVC = segue.destination as? RankVC {
            rankVC.initData(user: user)
        }
        else if let followerVC = segue.destination as? FollowerVC {
            followerVC.initData(user: user)
        }
        else if let followedUserVC = segue.destination as? FollowedUserVC {
            followedUserVC.initData(user: user)
        }
        else if let unmatchedEntriesVC = segue.destination as? UnmatchedEntriesVC, let unmatchedEntries = sender as? [CompetitionEntry] {
            unmatchedEntriesVC.initData(unmatchedEntries: unmatchedEntries)
        }
    }
}

extension ProfileVC: ProfileInfoCollectionViewHeaderDelegate {
    
    
    func unfollowedUser(user: User) {
        delegate?.unfollowedUser(user: user)
    }
}

extension ProfileVC: UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return competitions.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PROFILE_COMPETITION_CELL, for: indexPath)
        
        if let profileCompetitionCell = cell as? ProfileCompetitionCell {
            
            let competition = competitions[indexPath.row]
            profileCompetitionCell.configureCell(competition: competition, userId: userId)
            
            return profileCompetitionCell
        }
        return ProfileCompetitionCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PROFILE_INFO_COLLECTION_VIEW_HEADER, for: indexPath)
        
        if let profileInfoCollectionViewHeader = view as? ProfileInfoCollectionViewHeader {
            
            profileInfoCollectionViewHeader.configureView(user: user, profileViewMode: profileViewMode, unmatchedCompetitionEntries: unmatchedCompetitionEntries, delegate: self)
            
            return profileInfoCollectionViewHeader
        }
        return ProfileInfoCollectionViewHeader()
    }
}

extension ProfileVC: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let competition = competitions[indexPath.row]
        showCompetition(competition: competition)
    }
}

extension ProfileVC: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemsPerRow: CGFloat = 3
        
        let paddingSpace = collectionViewSectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return collectionViewSectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return collectionViewSectionInsets.left
    }
}
