//
//  UserVC.swift
//  Versus
//
//  Created by JT Smrdel on 3/16/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import UIKit

protocol UserVCDelegate {
    func userUpdated()
}

class UserVC: UIViewController {

    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    private let entryService = EntryService.instance
    private let competitionService = CompetitionService.instance
    private let followerService = FollowerService.instance
    
    private let collectionViewSectionInsets = UIEdgeInsets(
        top: 2.0,
        left: 2.0,
        bottom: 2.0,
        right: 2.0
    )
    
    private var delegate: UserVCDelegate?
    private var user: User!
    private var competitions = [Competition]()
    private var entries = [Entry]()
    
    
    
    
    init(user: User, delegate: UserVCDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
        self.delegate = delegate
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileCollectionView.register(
            UINib(nibName: "UserInfoView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "UserInfoView"
        )
        
        usernameLabel.text = String(format: "@%@", user.username)
        
        // Hide until options are included.
        optionsButton.isHidden = true
    }

    
    
    
    @IBAction func optionsButtonAction() {
        displayOptions()
    }
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    private func loadEntries() {
        
        entryService.loadEntries(
            userId: user.id
        ) { [weak self] (entries, errorMessage) in
            
            DispatchQueue.main.async {
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                guard let entries = entries else {
                    self?.displayMessage(message: "Unable to load entries")
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
        
    }
    
    
    private func showCompetition(competition: Competition) {
        
        let competitionStoryboard = UIStoryboard(name: COMPETITION, bundle: nil)
        let viewController = competitionStoryboard.instantiateInitialViewController()
        
        if let viewCompetitionVC = viewController as? ViewCompetitionVC {
            
            viewCompetitionVC.initData(competition: competition)
            navigationController?.pushViewController(viewCompetitionVC, animated: true)
        }
    }
    
    
    private func followUser() {
        
        let userId = user.id
        
        followerService.followUser(
            userId: userId
        ) { [weak self] (errorMessage) in
            
            DispatchQueue.main.async {
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                CurrentAccount.addFollowedUserId(id: userId)
                self?.delegate?.userUpdated()
                self?.profileCollectionView.reloadData()
            }
        }
    }
    
    
    private func unfollowUser() {
        
        let unfollowAlert = UIAlertController(
            title: "Confirm Unfollow",
            message: "Are you sure you want to unfollow @\(user.username)",
            preferredStyle: .actionSheet
        )
        
        let unfollowAction = UIAlertAction(
            title: "Unfollow",
            style: .destructive
        ) { (action) in
            
            self.loadAndUnfollowUser()
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
    
    
    private func loadAndUnfollowUser() {
        
        let userId = CurrentAccount.user.id
        let userFollowedId = user.id
        
        followerService.getFollowedUser(
            userId: userId,
            followedUserId: user.id
        ) { [weak self] (followedUser, errorMessage) in
            
            if let errorMessage = errorMessage {
                DispatchQueue.main.async {
                    self?.displayMessage(message: errorMessage)
                }
                return
            }
            
            guard let followedUser = followedUser else {
                DispatchQueue.main.async {
                    self?.displayMessage(message: "Unable to unfollow user")
                }
                return
            }
            
            self?.followerService.unfollow(
                followerId: followedUser.id,
                completion: { [weak self] (errorMessage) in
                    
                    DispatchQueue.main.async {
                        
                        if let errorMessage = errorMessage {
                            self?.displayMessage(message: errorMessage)
                            return
                        }
                        
                        CurrentAccount.removeFollowedUserId(id: userFollowedId)
                        self?.delegate?.userUpdated()
                        self?.profileCollectionView.reloadData()
                    }
                }
            )
        }
    }
}




extension UserVC: UserInfoViewDelegate {
    
    
    func follow() {
        followUser()
    }
    
    
    func unfollow() {
        unfollowUser()
    }
    
    
    func viewWins() {
        
    }
    
    
    func viewRanks() {
        
        let rankVC = RankVC(user: user)
        navigationController?.pushViewController(
            rankVC,
            animated: true
        )
    }
    
    
    func viewFollowedUsers() {
        
        let followedUserVC = FollowedUserVC(user: user)
        navigationController?.pushViewController(
            followedUserVC,
            animated: true
        )
    }
    
    
    func viewFollowers() {
        
        let followerVC = FollowerVC(user: user)
        navigationController?.pushViewController(
            followerVC,
            animated: true
        )
    }
    
    
    func viewEntries() {
        
        let entriesVC = EntriesVC(entries: entries)
        navigationController?.pushViewController(
            entriesVC,
            animated: true
        )
    }
}




extension UserVC: UICollectionViewDataSource {
    
    
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
        
        let userInfoView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "UserInfoView",
            for: indexPath
        ) as! UserInfoView
        
        userInfoView.configureView(
            user: user,
            entries: entries,
            delegate: self
        )
        return userInfoView
    }
}




extension UserVC: UICollectionViewDelegate {
    
    
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




extension UserVC: UICollectionViewDelegateFlowLayout {
    
    
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
