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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileInfoContainerView: UIView!
    @IBOutlet weak var competitionCollectionView: UICollectionView!
    @IBOutlet weak var competitionCollectionViewHeight: NSLayoutConstraint!
    
    
    private let competitionService = CompetitionService.instance
    private let accountService = AccountService.instance
    private let pendingImageOperations = ImageOperations()
    
    private let collectionViewSectionInsets = UIEdgeInsets(
        top: 2.0,
        left: 2.0,
        bottom: 2.0,
        right: 2.0
    )
    
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
        
        addProfileInfoViewController()
        
        registerCells()
        
        configureViewMode()
        
        configureView()
        
        configureRefreshControl()
        
        loadCompetitions()
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        competitionCollectionViewHeight.constant = competitionCollectionView.contentSize.height
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
        
        profileInfoVC.reloadUserData()
        
        loadCompetitions()
    }
    
    
    
    private func addProfileInfoViewController() {
        
        profileInfoVC = ProfileInfoVC(
            user: user,
            delegate: self,
            viewMode: viewMode
        )
        addChild(profileInfoVC)
        profileInfoVC.view.frame = CGRect(
            origin: .zero,
            size: profileInfoContainerView.frame.size
        )
        profileInfoContainerView.addSubview(profileInfoVC.view)
        profileInfoVC.didMove(toParent: self)
    }
    
    
    private func registerCells() {
        
        competitionCollectionView.register(
            UINib(nibName: "ProfileCompetitionCell", bundle: nil),
            forCellWithReuseIdentifier: "ProfileCompetitionCell"
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
        
        scrollView.refreshControl = refreshControl
    }
    
    
    private func loadCompetitions() {
        
        competitionService.loadUserCompetitions(
            userId: user.id
        ) { [weak self] (competitions, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.scrollView.refreshControl?.endRefreshing()
                
                if let error = error {
                    self.displayMessage(message: error)
                }
                
                self.competitions = competitions
                self.competitionCollectionView.reloadData()
            }
        }
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
                    
                    self.competitionCollectionView.reloadItems(
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


// MARK: - EditCurrentUserVCDelegate
extension UserVC: EditCurrentUserVCDelegate {
    
    func userUpdated() {
        profileInfoVC.reloadUserData()
    }
}


extension UserVC: ProfileInfoVCDelegate {
    
    func userReloaded(user: User) {
        
        self.user = user
        delegate?.userUpdated()
        configureView()
    }
}
