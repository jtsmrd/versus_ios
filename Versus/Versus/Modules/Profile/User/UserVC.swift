//
//  UserVC.swift
//  Versus
//
//  Created by JT Smrdel on 3/16/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import UIKit

class UserVC: UIViewController {

    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
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




extension UserVC: UserInfoViewDelegate {
    
    
    func unfollowUser(user: User) {
        
    }
    
    
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
