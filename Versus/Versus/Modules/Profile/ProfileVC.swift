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
    
    private let userService = UserService.instance
    private let accountService = AccountService.instance
    
    private var userId: String?
    private var user: User?
    private var profileViewMode: ProfileViewMode = .viewOnly
    
    var delegate: ProfileVCDelegate?
    let competitionCollectionViewSectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userId == nil {
            userId = CurrentUser.userId
            profileViewMode = .edit
        }
        guard let userId = userId else { return }
        loadUser(userId: userId)
    }

    
    func initData(userId: String) {
        self.userId = userId
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
    
    
    private func loadUser(userId: String) {
        userService.getUser(userId: userId) { (awsUser, customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.displayError(error: customError)
                    return
                }
                guard let awsUser = awsUser else {
                    self.displayError(error: CustomError(error: nil, message: "Unable to load user"))
                    return
                }
                self.user = User(awsUser: awsUser)
                self.configureView()
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

        // Get user's competitions
        user?.getCompetitions { (success, error) in
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
        let optionsAlertController = UIAlertController(
            title: "Profile Options",
            message: nil,
            preferredStyle: .actionSheet
        )
        optionsAlertController.addAction(
            UIAlertAction(
                title: "Edit Profile",
                style: .default,
                handler: { (action) in
                    self.displayEditProfile()
                }
            )
        )
        optionsAlertController.addAction(
            UIAlertAction(
                title: "Change Password",
                style: .default,
                handler: { (action) in
            
                }
            )
        )
        optionsAlertController.addAction(
            UIAlertAction(
                title: "Sign Out",
                style: .default,
                handler: { (action) in
                    self.signOut()
                }
            )
        )
        optionsAlertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        present(optionsAlertController, animated: true, completion: nil)
    }
    
    
    private func displayEditProfile() {
        if let editProfileVC = UIStoryboard(name: MAIN, bundle: nil).instantiateViewController(withIdentifier: EDIT_PROFILE_VC) as? EditProfileVC {
            present(editProfileVC, animated: true, completion: nil)
        }
    }
    
    
    private func signOut() {
        accountService.signOut { (success) in
            if success {
                DispatchQueue.main.async {
                    if let loginVC = UIStoryboard(name: LOGIN, bundle: nil).instantiateInitialViewController() {
                        appDelegate.window?.rootViewController = loginVC
                        appDelegate.window?.makeKeyAndVisible()
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
    }
}

extension ProfileVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        return user?.competitions.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PROFILE_COMPETITION_CELL,
            for: indexPath) as? ProfileCompetitionCell {
            cell.configureCell(competitionIndex: indexPath.row, user: user)
            return cell
        }
        return ProfileCompetitionCell()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
        if let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
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
        showCompetition(competition: (user?.competitions[indexPath.row])!)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

extension ProfileVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemsPerRow: CGFloat = 3
        
        let paddingSpace = competitionCollectionViewSectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return competitionCollectionViewSectionInsets
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return competitionCollectionViewSectionInsets.left
    }
}
