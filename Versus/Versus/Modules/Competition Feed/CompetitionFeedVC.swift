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

    @IBOutlet weak var competitionTableView: UITableView!
    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var noResultsInfoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    
    
    // MARK: - Constants
    
    private let notificationCenter = NotificationCenter.default
    private let ROW_HEIGHT: CGFloat = 188.0
    private let PREFETCH_SCROLL_PERCENTAGE: CGFloat = 0.50
    
    
    // MARK: - Variables
    
    private var competitionManager: CompetitionManager!
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

        competitionManager = CompetitionManager(delegate: self)
        
        competitionTableView.register(
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
            competitionManager.getCompetitions(
                queryType: .featured(categoryId: nil)
            )
            
        case .followedUsers:
            let user = CurrentAccount.user
            competitionManager.getCompetitions(
                queryType: .followedUsers(userId: user.id)
            )
            
        default:
            break
        }
    }
    
    
    /// When a Competition is update (user voted), update the competition object and reload that row.
    /// - Parameter notification: Payload containing the updated Competition.
    @objc func competitionUpdated(
        notification: Foundation.Notification
    ) {
        
        if let competition = notification.object as? Competition {
            
            let selectedIndexPath = competitionTableView.indexPathForSelectedRow
            
            if let selectedIndexPath = selectedIndexPath {
                
                let index = competitions.firstIndex { (existingCompetition) -> Bool in
                    existingCompetition.id == competition.id
                }
                
                if let index = index {
                    competitions[index] = competition
                }
                
                competitionTableView.reloadRows(
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
        
        competitionTableView.refreshControl = refreshControl
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
        var downloadsInProgress = pendingImageOperations.asyncDownloadsInProgress

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

                if let competitionCell = self.competitionTableView.cellForRow(at: indexPath) as? CompetitionCell {
                    competitionCell.updateImages()
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


private extension CompetitionFeedVC {

    private func calculateIndexPathsToReload(
        from newCompetitions: [Competition]
    ) -> [IndexPath] {
        
        let startIndex = competitions.count - newCompetitions.count
        let endIndex = startIndex + newCompetitions.count
        let indexPaths = (startIndex..<endIndex).map {
            IndexPath(row: $0, section: 0)
        }
        
        return indexPaths
    }
    
    func visibleIndexPathsToReload(
        intersecting indexPaths: [IndexPath]
    ) -> [IndexPath] {
        
        let indexPathsForVisibleRows = competitionTableView.indexPathsForVisibleRows ?? []
        
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        
        return Array(indexPathsIntersection)
    }
}


// MARK: - CompetitionManagerDelegate

extension CompetitionFeedVC: CompetitionManagerDelegate {
    
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
                self.reloadButton.isEnabled = true
                self.activityIndicator.stopAnimating()
                self.competitionTableView.refreshControl?.endRefreshing()
                self.competitionTableView.reloadData()
                return
            }
            
            self.competitionTableView.beginUpdates()
            self.competitionTableView.insertRows(
                at: newIndexPaths,
                with: .none
            )
            self.competitionTableView.endUpdates()
        }
    }
    
    func didFailWithError(error: String) {
        DispatchQueue.main.async {
            self.displayMessage(message: error)
        }
    }
}


// MARK: - UITableViewDataSourcePrefetching

extension CompetitionFeedVC: UITableViewDataSourcePrefetching {
    
    func tableView(
        _ tableView: UITableView,
        prefetchRowsAt indexPaths: [IndexPath]
    ) {
        // No need to fetch if there are no more results
        guard competitionManager.hasMoreResults else { return }
        
        // Get the row number of the last visible row
        guard let maxVisibleRowNumber =
            tableView.indexPathsForVisibleRows?.max()?.row else { return }
        
        // Calculate the percentage of total rows that are scolled to
        let scrollPercentage = CGFloat(maxVisibleRowNumber) / CGFloat(competitions.count)
        
        // Only prefetch when the scrolled percentage is >= 85%
        guard scrollPercentage >= PREFETCH_SCROLL_PERCENTAGE else { return }
        
        competitionManager.fetchMoreResults()
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
        
        if competition.rightEntry.imageDownloadState == .new && competition.leftEntry.imageDownloadState == .new {
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
        return ROW_HEIGHT
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
