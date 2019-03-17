//
//  CurrentUserVC.swift
//  Versus
//
//  Created by JT Smrdel on 3/16/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import UIKit

class CurrentUserVC: UIViewController {

    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    private let userService = UserService.instance
    private let accountService = AccountService.instance
    private let entryService = EntryService.instance
    private let competitionService = CompetitionService.instance
    
    private let collectionViewSectionInsets = UIEdgeInsets(
        top: 2.0,
        left: 2.0,
        bottom: 2.0,
        right: 2.0
    )
    
    private var user: User!
    private var competitions = [Competition]()
    private var entries = [Entry]()
    
    
    
    
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
        entries = user.entries
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileCollectionView.register(
            UINib(nibName: "CurrentUserInfoView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "CurrentUserInfoView"
        )
        
        usernameLabel.text = String(format: "@%@", user.username)
    }


    
    @IBAction func optionsButtonAction() {
        displayOptions()
    }
    
    
    
    private func loadEntries() {
        
        entryService.getUnmatchedEntries(
            userId: user.id
        ) { [weak self] (entries, errorMessage) in
            
            DispatchQueue.main.async {
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                self?.entries = entries
                self?.profileCollectionView.reloadData()
            }
        }
    }
    
    
    
    private func loadCompetitions() {
        
        
    }
    
    
    
    private func displayOptions() {
        
        let optionsAlert = UIAlertController(
            title: "Profile Options",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let editProfileAction = UIAlertAction(
            title: "Edit Profile",
            style: .default
        ) { (action) in
            self.displayEditProfile()
        }
        
        let changePasswordAction = UIAlertAction(
            title: "Change Password",
            style: .default
        ) { (action) in
            
        }
        
        let signOutAction = UIAlertAction(
            title: "Sign Out",
            style: .default
        ) { (action) in
            self.signOut()
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        optionsAlert.addAction(editProfileAction)
        optionsAlert.addAction(changePasswordAction)
        optionsAlert.addAction(signOutAction)
        optionsAlert.addAction(cancelAction)
        
        present(optionsAlert, animated: true, completion: nil)
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
    
    
    
    private func displayEditProfile() {
        
        let editCurrentUserVC = EditCurrentUserVC(
            user: user,
            delegate: self
        )
        
        present(
            editCurrentUserVC,
            animated: true,
            completion: nil
        )
    }
    
    
    
    private func showCompetition(competition: Competition) {
        
//        let competitionStoryboard = UIStoryboard(name: COMPETITION, bundle: nil)
//        let viewController = competitionStoryboard.instantiateInitialViewController()
//
//        if let viewCompetitionVC = viewController as? ViewCompetitionVC {
//
//            viewCompetitionVC.initData(competition: competition)
//            navigationController?.pushViewController(viewCompetitionVC, animated: true)
//        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let rankVC = segue.destination as? RankVC {
            rankVC.initData(user: user)
        }
        else if let followerVC = segue.destination as? FollowerVC {
            followerVC.initData(user: user)
        }
        else if let followedUserVC = segue.destination as? FollowedUserVC {
            followedUserVC.initData(user: user)
        }
        else if let unmatchedEntriesVC = segue.destination as? UnmatchedEntriesVC, let unmatchedEntries = sender as? [Entry] {
            unmatchedEntriesVC.initData(unmatchedEntries: unmatchedEntries)
        }
    }
}




extension CurrentUserVC: UICollectionViewDataSource {
    
    
    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        
        return 1
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        return competitions.count
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PROFILE_COMPETITION_CELL,
            for: indexPath
        )
        
        if let profileCompetitionCell = cell as? ProfileCompetitionCell {
            
            let competition = competitions[indexPath.row]
            //TODO
            //            profileCompetitionCell.configureCell(competition: competition, userId: userId)
            
            return profileCompetitionCell
        }
        return ProfileCompetitionCell()
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        let profileInfoView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "CurrentUserInfoView",
            for: indexPath
        ) as! CurrentUserInfoView
        
        profileInfoView.configureView(
            user: user,
            entries: entries,
            delegate: self
        )
        return profileInfoView
    }
}




extension CurrentUserVC: CurrentUserInfoViewDelegate {
    
    
    func viewWins() {
        
    }
    
    
    func viewRanks() {
        
    }
    
    
    func viewFollowedUsers() {
        
    }
    
    
    func viewFollowers() {
        
    }
    
    
    func viewEntries() {
        
    }
    
    
    func errorOccurred(errorMessage: String) {
        displayMessage(message: errorMessage)
    }
}




extension CurrentUserVC: UICollectionViewDelegate {
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        collectionView.deselectItem(
            at: indexPath,
            animated: false
        )
        
        let competition = competitions[indexPath.row]
        showCompetition(competition: competition)
    }
}




extension CurrentUserVC: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let itemsPerRow: CGFloat = 3
        
        let paddingSpace = collectionViewSectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(
            width: widthPerItem,
            height: widthPerItem
        )
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        
        return collectionViewSectionInsets
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        
        return collectionViewSectionInsets.left
    }
}




extension CurrentUserVC: EditCurrentUserVCDelegate {
    
    
    func userUpdated() {
        
        user = CurrentAccount.user
        profileCollectionView.reloadData()
    }
}
