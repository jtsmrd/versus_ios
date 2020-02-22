//
//  CompetitionFeedVC.swift
//  Versus
//
//  Created by JT Smrdel on 2/22/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

enum CompetitionFeedType {
    case featured
    case followedUsers
}

class CompetitionFeedVC: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var competitionsTableView: UITableView!
    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var noResultsInfoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    
    
    // MARK: - Constants
    
    private let competitionService = CompetitionService.instance
    private let notificationCenter = NotificationCenter.default
    
    
    // MARK: - Variables
    
    private var type: CompetitionFeedType!
    private var competitions = [Competition]()
    private var pendingImageOperations = ImageOperations()
    private var refreshControl: UIRefreshControl!
    
    
    // MARK: - Initializers
    
    init(type: CompetitionFeedType) {
        super.init(nibName: nil, bundle: nil)
        
        self.type = type
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        competitionsTableView.register(
            UINib(nibName: COMPETITION_CELL, bundle: nil),
            forCellReuseIdentifier: COMPETITION_CELL
        )
        
        switch type {
        case .featured:
            noResultsInfoLabel.text = "No Featured Competitions at the moment. Check back later."
            
        case .followedUsers:
            noResultsInfoLabel.text = "No Competitions to display for users you follow. Go follow some people!"
            
        case .none:
            return
        }
        
        configureRefreshControl()
        
        refreshControl.beginRefreshing()
        getCompetitions()
        
        notificationCenter.addObserver(
            self,
            selector: #selector(CompetitionFeedVC.competitionUpdated(notification:)),
            name: NSNotification.Name.OnCompetitionUpdated,
            object: nil
        )
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check for competitions when the user switches back to this screen
        // only there are no competitions for the specific competitions feed
        if noResultsView.isHidden == false {
            getCompetitions()
        }
    }

    
    // MARK: - Actions
    
    @IBAction func reloadButtonAction() {
        
        reloadButton.isEnabled = false
        activityIndicator.startAnimating()
        getCompetitions()
    }
    
    
    @objc func getCompetitions() {
        
        switch type {
        case .featured:
            getFeauredCompetitions()
            
        case .followedUsers:
            getFollowedUserCompetitions()
            
        case .none:
            return
        }
    }
    
    
    /// When a Competition is update (user voted), update the competition object and reload that row.
    /// - Parameter notification: Payload containing the updated Competition.
    @objc func competitionUpdated(notification: Foundation.Notification) {
        
        if let competition = notification.object as? Competition {
            
            let selectedIndexPath = competitionsTableView.indexPathForSelectedRow
            
            if let selectedIndexPath = selectedIndexPath {
                
                let index = competitions.firstIndex { (existingCompetition) -> Bool in
                    existingCompetition.id == competition.id
                }
                
                if let index = index {
                    competitions[index] = competition
                }
                
                competitionsTableView.reloadRows(
                    at: [selectedIndexPath],
                    with: .automatic
                )
            }
        }
    }
    
    
    // MARK: - Private Methods
    
    private func configureRefreshControl() {
        
        let attributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)]
        let refreshTitle = NSAttributedString(
            string: "Loading Competitions",
            attributes: attributes
        )
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        refreshControl.attributedTitle = refreshTitle
        refreshControl.addTarget(
            self,
            action: #selector(CompetitionFeedVC.getCompetitions),
            for: .valueChanged
        )
        
        competitionsTableView.refreshControl = refreshControl
    }
    
    
    private func getFeauredCompetitions() {
        
        competitionService.loadFeaturedCompetitions(
            categoryId: nil
        ) { [weak self] (competitions, error) in
            guard let self = self else { return }
            
            self.handleGetCompetitionsResponse(
                competitions: competitions,
                error: error
            )
        }
    }
    
    
    private func getFollowedUserCompetitions() {
        
        let user = CurrentAccount.user
        
        competitionService.loadFollowedUserCompetitions(
            userId: user.id
        ) { [weak self] (competitions, error) in
            guard let self = self else { return }
            
            self.handleGetCompetitionsResponse(
                competitions: competitions,
                error: error
            )
        }
    }
    
    
    private func handleGetCompetitionsResponse(
        competitions: [Competition]?,
        error: String?
    ) {
        DispatchQueue.main.async {
            
            self.reloadButton.isEnabled = true
            self.activityIndicator.stopAnimating()
            self.competitionsTableView.refreshControl?.endRefreshing()
            
            if let error = error {
                self.displayMessage(message: error)
            }
            else if let competitions = competitions {
                
                self.competitions = competitions
                self.competitionsTableView.reloadData()
            }
            else {
                self.displayMessage(
                    message: "Unable to load competitions."
                )
            }
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
    
    
    // MARK: - Image Operations
    
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
                
                self.competitionsTableView.reloadRows(
                    at: [indexPath],
                    with: .none
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
        
        if let pathsArray = competitionsTableView.indexPathsForVisibleRows {

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

                let competition = competitions[indexPath.row]

                startCompetitionImageDownloadFor(
                    competition: competition,
                    indexPath: indexPath
                )
            }
        }
    }
}


// MARK: - UITableViewDataSource

extension CompetitionFeedVC: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        let count = competitions.count
        noResultsView.isHidden = count > 0 ? true : false
        return count
    }
    
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let competitionCell = tableView.dequeueReusableCell(
            withIdentifier: COMPETITION_CELL,
            for: indexPath
        ) as! CompetitionCell
        
        let competition = competitions[indexPath.row]
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
    
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        return 188
    }
}


// MARK: - UITableViewDelegate

extension CompetitionFeedVC: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
//        tableView.deselectRow(
//            at: indexPath,
//            animated: false
//        )
        
//        selectedIndexPath = indexPath
        
        let competition = competitions[indexPath.row]
        
        showCompetition(
            competition: competition
        )
    }
}


// MARK: - UIScrollViewDelegate

extension CompetitionFeedVC: UIScrollViewDelegate {
    
    
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
