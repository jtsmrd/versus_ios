//
//  UserVC.swift
//  Versus
//
//  Created by JT Smrdel on 3/16/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import UIKit

enum UserViewMode {
    case edit
    case readOnly
}

protocol UserVCDelegate {
    func userUpdated()
}

class UserVC: UIViewController {

    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var competitionCollectionView: UICollectionView!
    
    
    private let accountService = AccountService.instance
    private let pendingImageOperations = ImageOperations()
    private let PREFETCH_SCROLL_PERCENTAGE: CGFloat = 0.50
    private let collectionViewSectionInsets = UIEdgeInsets(
        top: 2.0,
        left: 2.0,
        bottom: 2.0,
        right: 2.0
    )
    
    private var competitionManager: CompetitionManager!
    private var user: User!
    private var viewMode: UserViewMode!
    private var profileInfoVC: ProfileInfoVC!
    private var delegate: UserVCDelegate?
    private var competitions = [Competition]()
    private var refreshControl: UIRefreshControl!
    
    
    init(
        user: User,
        viewMode: UserViewMode = .readOnly,
        delegate: UserVCDelegate? = nil
    ) {
        super.init(nibName: nil, bundle: nil)
        
        self.user = user
        self.viewMode = viewMode
        self.delegate = delegate
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        competitionManager = CompetitionManager(delegate: self)
        addProfileInfoViewController()
        registerCells()
        configureViewMode()
        configureView()
        configureRefreshControl()
        loadCompetitions()
    }
    
    
    
    @IBAction func optionsButtonAction() {
        
        switch viewMode {
            
        case .edit:
            displayEditOptions()
            
        case .readOnly:
            displayReadOnlyOptions()
            
        default:
            break
        }
    }
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @objc func reloadUser() {
        
        profileInfoVC.loadUserData(shouldLoadEntries: true)
        
        loadCompetitions()
    }
    
    
    
    private func addProfileInfoViewController() {
        
        profileInfoVC = ProfileInfoVC(
            user: user,
            delegate: self,
            viewMode: viewMode
        )
        addChild(profileInfoVC)
        profileInfoVC.didMove(toParent: self)
    }
    
    
    private func registerCells() {
        
        competitionCollectionView.register(
            UINib(nibName: "ProfileCompetitionCell", bundle: nil),
            forCellWithReuseIdentifier: "ProfileCompetitionCell"
        )
        
        competitionCollectionView.register(
            UINib(nibName: "ProfileInfoCell", bundle: nil),
            forCellWithReuseIdentifier: "ProfileInfoCell"
        )
        
        competitionCollectionView.register(
            UINib(nibName: "NoUserCompetitionsCell", bundle: nil),
            forCellWithReuseIdentifier: "NoUserCompetitionsCell"
        )
    }
    
    
    private func configureViewMode() {
        
        switch viewMode {
            
        case .edit:
            backButton.isHidden = true
            
        case .readOnly:
            break
            
        default:
            break
        }
    }
    
    
    private func configureView() {
        usernameLabel.text = user.username.withAtSignPrefix
    }
    
    
    private func configureRefreshControl() {
        
        let attributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)]
        let refreshTitle = NSAttributedString(
            string: "Updating",
            attributes: attributes
        )
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        refreshControl.attributedTitle = refreshTitle
        refreshControl.addTarget(
            self,
            action: #selector(UserVC.reloadUser),
            for: .valueChanged
        )
        
        competitionCollectionView.refreshControl = refreshControl
    }
    
    
    private func loadCompetitions() {
        
        competitionManager.getCompetitions(
            queryType: .user(userId: user.id)
        )
    }
    
    
    private func displayReadOnlyOptions() {
        
    }
    
    
    private func displayEditOptions() {
        
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
        
        let competitionVC = CompetitionVC(competition: competition)
        navigationController?.pushViewController(
            competitionVC,
            animated: true
        )
    }
    
    
    
    // MARK: - Image Operations
    
    private func startEntryImageDownloadFor(
        entry: Entry,
        indexPath: IndexPath
    ) {
        var downloadsInProgress = pendingImageOperations.asyncDownloadsInProgress
        
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
                
                if let profileCompetitionCell = self.competitionCollectionView.cellForItem(at: indexPath) as? ProfileCompetitionCell {
                    profileCompetitionCell.updateImage()
                }
                else {
                    debugPrint("Not Cell")
                }
            }
        }
        
        // Add the operation to the collection of downloads in progress.
        downloadsInProgress[indexPath] = downloadOperation
        
        // Add the operation to the queue to start downloading.
        pendingImageOperations.asyncDownloadQueue.addOperation(
            downloadOperation
        )
    }
}


private extension UserVC {

    private func calculateIndexPathsToReload(
        from newCompetitions: [Competition]
    ) -> [IndexPath] {
        
        let startIndex = competitions.count - newCompetitions.count
        let endIndex = startIndex + newCompetitions.count
        let indexPaths = (startIndex..<endIndex).map {
            IndexPath(row: $0, section: 1)
        }
        
        return indexPaths
    }
    
    func visibleIndexPathsToReload(
        intersecting indexPaths: [IndexPath]
    ) -> [IndexPath] {
        
        let indexPathsForVisibleRows = competitionCollectionView.indexPathsForVisibleItems
        
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        
        return Array(indexPathsIntersection)
    }
}


// MARK: - CompetitionManagerDelegate

extension UserVC: CompetitionManagerDelegate {
    
    func competitionResultsUpdated(
        competitions: [Competition],
        isNewRequest: Bool
    ) {
        if isNewRequest {
            self.competitions = competitions
        }
        else {
            self.competitions.append(contentsOf: competitions)
        }
        
        DispatchQueue.main.async {
            
            var newIndexPathsToReload: [IndexPath]?
            if !isNewRequest {
                newIndexPathsToReload = self.calculateIndexPathsToReload(
                    from: competitions
                )
            }
            
            guard let newIndexPaths = newIndexPathsToReload else {
                self.competitionCollectionView.refreshControl?.endRefreshing()
                self.competitionCollectionView.reloadData()
                return
            }
            
            self.competitionCollectionView.insertItems(
                at: newIndexPaths
            )
        }
    }
    
    func didFailWithError(error: String) {
        DispatchQueue.main.async {
            self.displayMessage(message: error)
        }
    }
}


extension UserVC: UICollectionViewDataSource {
    
    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        return 2
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if section == 0 {
            return 1
        }
        else {
            if !competitions.isEmpty {
                return competitions.count
            }
            else {
                return 1    // No competitions cell
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProfileInfoCell",
                for: indexPath
            ) as! ProfileInfoCell
            cell.configureCell(
                profileInfoView: profileInfoVC.view
            )
            return cell
        }
        else {
            
            if !competitions.isEmpty {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PROFILE_COMPETITION_CELL,
                    for: indexPath
                ) as! ProfileCompetitionCell
                
                let competition = competitions[indexPath.row]
                var userEntry: Entry!
                
                if competition.leftEntry.user.id == user.id {
                    userEntry = competition.leftEntry
                }
                else {
                    userEntry = competition.rightEntry
                }
                
                cell.configureCell(
                    entry: userEntry
                )
                
                if userEntry.imageDownloadState == .new {
                    startEntryImageDownloadFor(
                        entry: userEntry,
                        indexPath: indexPath
                    )
                }
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "NoUserCompetitionsCell",
                    for: indexPath
                )
                return cell
            }
        }
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
        
        if indexPath.section == 1 && !competitions.isEmpty {
            let competition = competitions[indexPath.row]
            showCompetition(competition: competition)
        }
    }
}




extension UserVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        if indexPath.section == 0 {
            return CGSize(
                width: collectionView.frame.width,
                height: profileInfoVC.view.frame.height
            )
        }
        else {
            
            if !competitions.isEmpty {
                let itemsPerRow: CGFloat = 3
                
                let paddingSpace = collectionViewSectionInsets.left * (itemsPerRow + 1)
                let availableWidth = view.frame.width - paddingSpace
                let widthPerItem = availableWidth / itemsPerRow
                
                return CGSize(
                    width: widthPerItem,
                    height: widthPerItem
                )
            }
            else {
                return CGSize(
                    width: collectionView.frame.width,
                    height: collectionView.frame.height - profileInfoVC.view.frame.height
                )
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        
        if section == 0 {
            return .zero
        }
        else {
            if !competitions.isEmpty {
                return collectionViewSectionInsets
            }
            else {
                return .zero
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        
        if section == 0 {
            return .zero
        }
        else {
            if !competitions.isEmpty {
                return collectionViewSectionInsets.left
            }
            else {
                return .zero
            }
        }
    }
}


extension UserVC: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        guard competitionManager.hasMoreResults else { return }
        
        guard let maxVisibleItemNumber = competitionCollectionView.indexPathsForVisibleItems.max()?.item else { return }
        
        let scrollPercentage = CGFloat(maxVisibleItemNumber) / CGFloat(competitions.count)
        
        guard scrollPercentage >= PREFETCH_SCROLL_PERCENTAGE else { return }
        
        competitionManager.fetchMoreResults()
    }
}


// MARK: - EditCurrentUserVCDelegate
extension UserVC: EditCurrentUserVCDelegate {
    
    func userUpdated() {
        profileInfoVC.loadUserData()
    }
}


extension UserVC: ProfileInfoVCDelegate {
    
    func userReloaded(user: User) {
        
        self.user = user
        delegate?.userUpdated()
        configureView()
    }
}
