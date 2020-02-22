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
    private let pendingImageOperations = ImageOperations()
    
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
        
        profileCollectionView.register(
            UINib(nibName: "ProfileCompetitionCell", bundle: nil),
            forCellWithReuseIdentifier: "ProfileCompetitionCell"
        )
        
        usernameLabel.text = user.username.withAtSignPrefix
        
        LeaderService.instance.getAllTimeLeaders { (leaders, error) in
            debugPrint(leaders)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadCompetitions()
        
        loadEntries()
    }


    
    
    @IBAction func optionsButtonAction() {
        displayOptions()
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
        
        competitionService.loadUserCompetitions(
            userId: user.id
        ) { [weak self] (competitions, errorMessage) in
            
            DispatchQueue.main.async {
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                guard let competitions = competitions else {
                    self?.displayMessage(message: "Unable to load competitions")
                    return
                }
                
                self?.competitions = competitions
                self?.profileCollectionView.reloadData()
            }
        }
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
        
        present(
            optionsAlert,
            animated: true,
            completion: nil
        )
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
        
        let competitionVC = CompetitionVC(competition: competition)
        competitionVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(
            competitionVC,
            animated: true
        )
    }
}




// MARK: - UICollectionViewDataSource
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
            var userEntry: Entry!
            
            if CurrentAccount.userIsMe(userId: competition.leftEntry.user.id) {
                userEntry = competition.leftEntry
            }
            else {
                userEntry = competition.rightEntry
            }
            
            profileCompetitionCell.configureCell(
                entry: userEntry
            )
            
            if userEntry.imageDownloadState == .new {
                
                startEntryImageDownloadFor(
                    entry: userEntry,
                    indexPath: indexPath
                )
            }
            
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




// MARK: - CurrentUserInfoViewDelegate
extension CurrentUserVC: CurrentUserInfoViewDelegate {
    
    
    func viewWins() {
        
    }
    
    
    func viewRanks() {
        
        let rankVC = RankVC(user: user)
        rankVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(
            rankVC,
            animated: true
        )
    }
    
    
    func viewFollowedUsers() {
        
        let followedUserVC = FollowedUserVC(user: user)
        followedUserVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(
            followedUserVC,
            animated: true
        )
    }
    
    
    func viewFollowers() {
        
        let followerVC = FollowerVC(user: user)
        followerVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(
            followerVC,
            animated: true
        )
    }
    
    
    func viewEntries() {
        
        let entriesVC = EntriesVC(entries: entries)
        entriesVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(
            entriesVC,
            animated: true
        )
    }
}




// MARK: - UICollectionViewDelegate
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




// MARK: - UICollectionViewDelegateFlowLayout
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




// MARK: - EditCurrentUserVCDelegate
extension CurrentUserVC: EditCurrentUserVCDelegate {
    
    
    func userUpdated() {
        
        user = CurrentAccount.user
        profileCollectionView.reloadData()
    }
}




// MARK: - Image Operations
extension CurrentUserVC {
    
    
    private func startEntryImageDownloadFor(
        entry: Entry,
        indexPath: IndexPath
    ) {
        
        var downloadsInProgress = pendingImageOperations.downloadsInProgress
        
        // Make sure there isn't already a download in progress.
        guard downloadsInProgress[indexPath] == nil else { return }
        
        let downloadOperation = DownloadEntryImageOperation(
            entry: entry
        )
        
        downloadOperation.completionBlock = {
            
            if downloadOperation.isCancelled { return }
            
            DispatchQueue.main.async {
                downloadsInProgress.removeValue(
                    forKey: indexPath
                )
                
                self.profileCollectionView.reloadItems(
                    at: [indexPath]
                )
            }
        }
        
        // Add the operation to the collection of downloads in progress.
        downloadsInProgress[indexPath] = downloadOperation
        
        // Add the operation to the queue to start downloading.
        pendingImageOperations.downloadQueue.addOperation(
            downloadOperation
        )
    }
    
    
    private func suspendAllOperations() {
        pendingImageOperations.downloadQueue.isSuspended = true
    }
    
    
    private func resumeAllOperations() {
        pendingImageOperations.downloadQueue.isSuspended = false
    }
    
    
    private func loadImagesForOnscreenCells() {
        
//        if let pathsArray = browseTableView.indexPathsForVisibleRows {
//
//            var downloadsInProgress =
//                pendingImageOperations.downloadsInProgress
//
//            let allPendingOperations = Set(
//                downloadsInProgress.keys
//            )
//            var toBeCancelled = allPendingOperations
//
//            let visiblePaths = Set(pathsArray)
//            toBeCancelled.subtract(visiblePaths)
//
//            var toBeStarted = visiblePaths
//            toBeStarted.subtract(allPendingOperations)
//
//            for indexPath in toBeCancelled {
//
//                if let pendingDownload = downloadsInProgress[indexPath] {
//                    pendingDownload.cancel()
//                }
//                downloadsInProgress.removeValue(
//                    forKey: indexPath
//                )
//            }
//
//            for indexPath in toBeStarted {
//
//                let competition = featuredCompetitions[indexPath.row]
//
//                startCompetitionImageDownloadFor(
//                    competition: competition,
//                    indexPath: indexPath
//                )
//            }
//        }
    }
}
