//
//  FeaturedFollowingVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class FeaturedFollowingVC: UIViewController {

    
    enum CompetitionFeedType {
        case featured
        case following
    }
    
    
    @IBOutlet weak var featuredCompetitionsContainerView: UIView!
    @IBOutlet weak var featuredTableView: UITableView!
    @IBOutlet weak var noFeaturedCompetitionsView: UIView!
    @IBOutlet weak var noFeaturedCompetitionsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noFeaturedCompetitionsReloadButton: UIButton!
    @IBOutlet weak var followedUserCompetitionsContainerView: UIView!
    @IBOutlet weak var followedUsersTableView: UITableView!
    @IBOutlet weak var noFollowedUserCompetitionsView: UIView!
    @IBOutlet weak var noFollowedUserCompetitionsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noFollowedUserCompetitionsReloadButton: UIButton!
    
    private let competitionService = CompetitionService.instance
    private let notificationCenter = NotificationCenter.default
    
    private var activeCompetitionFeedType: CompetitionFeedType = .featured
    private var featuredCompetitions = [Competition]()
    private var followedUserCompetitions = [Competition]()
    private let pendingImageOperations = ImageOperations()
    private var featuredRefreshControl: UIRefreshControl!
    private var followedRefreshControl: UIRefreshControl!
    private var selectedIndexPath: IndexPath?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        featuredTableView.register(
            UINib(nibName: COMPETITION_CELL, bundle: nil),
            forCellReuseIdentifier: COMPETITION_CELL
        )
        
        followedUsersTableView.register(
            UINib(nibName: COMPETITION_CELL, bundle: nil),
            forCellReuseIdentifier: COMPETITION_CELL
        )
        
        let attributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)]
        let refreshTitle = NSAttributedString(
            string: "Loading Competitions",
            attributes: attributes
        )
        
        featuredRefreshControl = UIRefreshControl()
        featuredRefreshControl.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        featuredRefreshControl.attributedTitle = refreshTitle
        featuredRefreshControl.addTarget(
            self,
            action: #selector(FeaturedFollowingVC.getFeaturedCompetitions),
            for: .valueChanged
        )
        
        featuredTableView.refreshControl = featuredRefreshControl
        
        followedRefreshControl = UIRefreshControl()
        followedRefreshControl.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        followedRefreshControl.attributedTitle = refreshTitle
        followedRefreshControl.addTarget(
            self,
            action: #selector(FeaturedFollowingVC.getFollowedUserCompetitions),
            for: .valueChanged
        )
        
        followedUsersTableView.refreshControl = followedRefreshControl
        
        featuredRefreshControl.beginRefreshing()
        getFeaturedCompetitions()
        
        followedRefreshControl.beginRefreshing()
        getFollowedUserCompetitions()
        
        notificationCenter.addObserver(
            self,
            selector: #selector(FeaturedFollowingVC.competitionUpdated(notification:)),
            name: NSNotification.Name.OnCompetitionUpdated,
            object: nil
        )
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check for featured/ followed user competitions when the user switches back to this screen
        // only there are no competitions for the specific competitions feed
        if noFeaturedCompetitionsView.isHidden == false {
            getFeaturedCompetitions()
        }
        
        if noFollowedUserCompetitionsView.isHidden == false {
            getFollowedUserCompetitions()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Request authorization for push notifications here, since it's the first screen the user
        // will see after signing up.
        appDelegate.registerForPushNotifications()
        
        selectedIndexPath = nil
    }
    
    
    
    
    /**
     
     */
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    
    
    
    @IBAction func featuredFollowingSegmentedControlAction(_ sender: UISegmentedControl) {
        
        activeCompetitionFeedType = sender.selectedSegmentIndex == 0 ? .featured : .following
        
        toggleCompetitionFeedTableView()
    }
    
    
    @IBAction func noFeaturedCompetitionsReloadButtonAction() {
        
        noFeaturedCompetitionsReloadButton.isEnabled = false
        noFeaturedCompetitionsActivityIndicator.startAnimating()
        getFeaturedCompetitions()
    }
    
    
    @IBAction func noFollowedUserCompetitionsReloadButtonAction() {
        
        noFollowedUserCompetitionsReloadButton.isEnabled = false
        noFollowedUserCompetitionsActivityIndicator.startAnimating()
        getFollowedUserCompetitions()
    }
    
    
    @objc func competitionUpdated(notification: Foundation.Notification) {
        
        if let competition = notification.object as? Competition {
            
            if let selectedIndexPath = selectedIndexPath {
                
                switch activeCompetitionFeedType {
                    
                case .featured:
                    
                    let index = featuredCompetitions.firstIndex { (existingCompetition) -> Bool in
                        existingCompetition.id == competition.id
                    }
                    
                    if let index = index {
                        featuredCompetitions[index] = competition
                    }
                    
                    featuredTableView.reloadRows(
                        at: [selectedIndexPath],
                        with: .automatic
                    )
                    
                case .following:
                    
                    let index = followedUserCompetitions.firstIndex { (existingCompetition) -> Bool in
                        existingCompetition.id == competition.id
                    }
                    
                    if let index = index {
                        followedUserCompetitions[index] = competition
                    }
                    
                    followedUsersTableView.reloadRows(
                        at: [selectedIndexPath],
                        with: .automatic
                    )
                }
            }
        }
    }
    
    
    @objc func getFeaturedCompetitions() {
        
        competitionService.loadFeaturedCompetitions(
            categoryId: nil
        ) { [weak self] (competitions, errorMessage) in
            
            DispatchQueue.main.async {
                
                self?.noFeaturedCompetitionsReloadButton.isEnabled = true
                self?.noFeaturedCompetitionsActivityIndicator.stopAnimating()
                self?.featuredTableView.refreshControl?.endRefreshing()
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                guard let competitions = competitions else {
                    self?.displayMessage(message: "Unable to load featured competitions")
                    return
                }
                
                self?.featuredCompetitions = competitions
                self?.featuredTableView.reloadData()
            }
        }
    }
    
    
    @objc func getFollowedUserCompetitions() {
        
        // TODO
        let user = CurrentAccount.user
        
        competitionService.loadFollowedUserCompetitions(
            userId: user.id
        ) { [weak self] (competitions, errorMessage) in
            
            DispatchQueue.main.async {
                
                self?.noFollowedUserCompetitionsReloadButton.isEnabled = true
                self?.noFollowedUserCompetitionsActivityIndicator.stopAnimating()
                self?.followedUsersTableView.refreshControl?.endRefreshing()
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                guard let competitions = competitions else {
                    self?.displayMessage(message: "Unable to load followed user competitions")
                    return
                }
                
                self?.followedUserCompetitions = competitions
                self?.followedUsersTableView.reloadData()
            }
        }
    }

    
    
    
    private func toggleCompetitionFeedTableView() {
        
        switch activeCompetitionFeedType {
            
        case .featured:
            followedUserCompetitionsContainerView.isHidden = true
            featuredCompetitionsContainerView.isHidden = false
            featuredTableView.reloadData()
            
        case .following:
            featuredCompetitionsContainerView.isHidden = true
            followedUserCompetitionsContainerView.isHidden = false
            followedUsersTableView.reloadData()
        }
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




// MARK: - UITableViewDataSource
extension FeaturedFollowingVC: UITableViewDataSource {
    
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        switch activeCompetitionFeedType {
            
        case .featured:
            
            let count = featuredCompetitions.count
            
            DispatchQueue.main.async {
                
                self.noFeaturedCompetitionsView.isHidden = count > 0 ? true : false
            }
            return count
            
        case .following:
            
            let count = followedUserCompetitions.count
            
            DispatchQueue.main.async {
                
                self.noFollowedUserCompetitionsView.isHidden = count > 0 ? true : false
            }
            return count
        }
    }
    
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: COMPETITION_CELL,
            for: indexPath
        )
        
        if let competitionCell = cell as? CompetitionCell {
            
            var competition: Competition!
            
            switch activeCompetitionFeedType {
                
            case .featured:
                competition = featuredCompetitions[indexPath.row]
                
            case .following:
                competition = followedUserCompetitions[indexPath.row]
            }
            // TODO
            competitionCell.configureCell(
                competition: competition
            )
            
            if competition.leftEntry.imageDownloadState == .new ||
                competition.rightEntry.imageDownloadState == .new {
                
                startCompetitionImageDownloadFor(
                    competition: competition,
                    indexPath: indexPath
                )
            }
            
            return competitionCell
        }
        return CompetitionCell()
    }
    
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        return 188
    }
}




// MARK: - UITableViewDelegate
extension FeaturedFollowingVC: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        tableView.deselectRow(
            at: indexPath,
            animated: false
        )
        
        selectedIndexPath = indexPath
        var competition: Competition!
        
        switch activeCompetitionFeedType {
            
        case .featured:
            competition = featuredCompetitions[indexPath.row]
            
        case .following:
            competition = followedUserCompetitions[indexPath.row]
        }
        
        showCompetition(
            competition: competition
        )
    }
}




// MARK: - UIScrollViewDelegate
extension FeaturedFollowingVC: UIScrollViewDelegate {
    
    
    func scrollViewWillBeginDragging(
        _ scrollView: UIScrollView
    ) {
        
//        suspendAllOperations()
    }
    
    
    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        
        if !decelerate {
//            loadImagesForOnscreenCells()
//            resumeAllOperations()
        }
    }
    
    
    func scrollViewDidEndDecelerating(
        _ scrollView: UIScrollView
    ) {
        
//        loadImagesForOnscreenCells()
//        resumeAllOperations()
    }
}




// MARK: - Image Operations
extension FeaturedFollowingVC {
    
    
    private func startCompetitionImageDownloadFor(
        competition: Competition,
        indexPath: IndexPath
    ) {
        
        var downloadsInProgress = pendingImageOperations.downloadsInProgress
        
        // Make sure there isn't already a download in progress.
        guard downloadsInProgress[indexPath] == nil else { return }
        
        let downloadOperation = DownloadCompetitionImageOperation(
            competition: competition
        )
        
        downloadOperation.completionBlock = {
            
            if downloadOperation.isCancelled { return }
            
            DispatchQueue.main.async {
                downloadsInProgress.removeValue(
                    forKey: indexPath
                )
                debugPrint("# FF Operation removed")
                
                switch self.activeCompetitionFeedType {
                    
                case .featured:
                    self.featuredTableView.reloadRows(
                        at: [indexPath],
                        with: .none
                    )
                    
                case .following:
                    self.followedUsersTableView.reloadRows(
                        at: [indexPath],
                        with: .none
                    )
                }
            }
        }
        
        // Add the operation to the collection of downloads in progress.
        downloadsInProgress[indexPath] = downloadOperation
        
        // Add the operation to the queue to start downloading.
        pendingImageOperations.downloadQueue.addOperation(
            downloadOperation
        )
        debugPrint("# FF Operation added")
    }
    
    
    private func suspendAllOperations() {
        pendingImageOperations.downloadQueue.isSuspended = true
    }
    
    
    private func resumeAllOperations() {
        pendingImageOperations.downloadQueue.isSuspended = false
    }
    
    
    private func loadImagesForOnscreenCells() {
        
        if let pathsArray = featuredTableView.indexPathsForVisibleRows {

            var downloadsInProgress =
                pendingImageOperations.downloadsInProgress

            let allPendingOperations = Set(
                downloadsInProgress.keys
            )
            var toBeCancelled = allPendingOperations

            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtract(visiblePaths)

            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)

            for indexPath in toBeCancelled {

                if let pendingDownload = downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                downloadsInProgress.removeValue(
                    forKey: indexPath
                )
            }

            for indexPath in toBeStarted {

                let competition = featuredCompetitions[indexPath.row]

                startCompetitionImageDownloadFor(
                    competition: competition,
                    indexPath: indexPath
                )
            }
        }
    }
}
