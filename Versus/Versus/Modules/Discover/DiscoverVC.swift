//
//  DiscoverVC.swift
//  Versus
//
//  Created by JT Smrdel on 2/29/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

class DiscoverVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var competitionTableView: UITableView!
    
    private let pendingImageOperations = ImageOperations()
    private let PREFETCH_SCROLL_PERCENTAGE: CGFloat = 0.50
    private let COMPETITION_CELL_HEIGHT: CGFloat = 188
    
    private var competitionManager: CompetitionManager!
    private var searchUserVC: SearchUserVC!
    private var leaderboardSelectorVC: LeaderboardSelectorVC!
    private var categorySelectorVC: CategorySelectorVC!
    private var competitions = [Competition]()
    private var refreshControl: UIRefreshControl!
    private var selectedCategory: Category?
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        competitionManager = CompetitionManager(delegate: self)
        addSearchUserViewController()
        addLeaderboardSelectorViewController()
        addCategorySelectorViewController()
        registerCells()
        configureView()
        configureRefreshControl()
        getFeaturedCompetitions()
    }

    
    @objc func reloadData() {
        getFeaturedCompetitions()
        leaderboardSelectorVC.reloadData()
    }
    
    
    private func registerCells() {
        
        competitionTableView.register(
            UINib(nibName: COMPETITION_CELL, bundle: nil),
            forCellReuseIdentifier: COMPETITION_CELL
        )
        
        competitionTableView.register(
            UINib(nibName: "LeaderboardSelectorCell", bundle: nil),
            forCellReuseIdentifier: "LeaderboardSelectorCell"
        )
        
        competitionTableView.register(
            UINib(nibName: "CategorySelectorCell", bundle: nil),
            forCellReuseIdentifier: "CategorySelectorCell"
        )
    }
    
    
    private func configureView() {
        
        searchBar.backgroundImage = UIImage()
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
            action: #selector(DiscoverVC.reloadData),
            for: .valueChanged
        )
        
        competitionTableView.refreshControl = refreshControl
    }
    
    
    private func addSearchUserViewController() {
        
        searchUserVC = SearchUserVC(delegate: self)
        searchBar.delegate = searchUserVC
        addChild(searchUserVC)
        searchUserVC.view.frame = CGRect(
            origin: .zero,
            size: searchContainerView.frame.size
        )
        searchContainerView.insertSubview(
            searchUserVC.view,
            at: 0
        )
        searchUserVC.didMove(toParent: self)
    }
    
    
    private func addLeaderboardSelectorViewController() {
        
        leaderboardSelectorVC = LeaderboardSelectorVC()
        addChild(leaderboardSelectorVC)
        leaderboardSelectorVC.didMove(toParent: self)
    }
    
    
    private func addCategorySelectorViewController() {
        
        categorySelectorVC = CategorySelectorVC(delegate: self)
        addChild(categorySelectorVC)
        categorySelectorVC.didMove(toParent: self)
    }
    
    
    private func getFeaturedCompetitions() {
        
        competitionManager.getCompetitions(
            queryType: .featured(
                categoryId: selectedCategory?.categoryType.rawValue
            )
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


private extension DiscoverVC {

    private func calculateIndexPathsToReload(
        from newCompetitions: [Competition]
    ) -> [IndexPath] {
        
        let startIndex = competitions.count - newCompetitions.count
        let endIndex = startIndex + newCompetitions.count
        let indexPaths = (startIndex..<endIndex).map {
            IndexPath(row: $0, section: 2)
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

extension DiscoverVC: CompetitionManagerDelegate {
    
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


extension DiscoverVC: CategorySelectorVCDelegate {
    
    func categorySelected(category: Category?) {
        selectedCategory = category
        getFeaturedCompetitions()
    }
}


// MARK: - SearchVCDelegate
extension DiscoverVC: SearchVCDelegate {
    
    func toggleSearchView(isHidden hidden: Bool) {
        
        if hidden {
            view.endEditing(true)
        }
        searchContainerView.isHidden = hidden
    }
}


// MARK: - UITableViewDataSource
extension DiscoverVC: UITableViewDataSource {
    
    func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return 3
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 1
        }
        else {
            return competitions.count
        }
    }
    
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "LeaderboardSelectorCell",
                for: indexPath
            ) as! LeaderboardSelectorCell
            cell.configureCell(
                leaderboardSelectorView: leaderboardSelectorVC.view
            )
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "CategorySelectorCell",
                for: indexPath
            ) as! CategorySelectorCell
            cell.configureCell(
                categorySelectorView: categorySelectorVC.view
            )
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: COMPETITION_CELL,
                for: indexPath
            ) as! CompetitionCell
            
            let competition = competitions[indexPath.row]
            
            cell.configureCell(
                competition: competition
            )
            
            if competition.leftEntry.imageDownloadState == .new &&
                competition.rightEntry.imageDownloadState == .new {
                startCompetitionImageDownloadFor(
                    competition: competition,
                    indexPath: indexPath
                )
            }
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return leaderboardSelectorVC.view.frame.height
        }
        else if indexPath.section == 1 {
            return categorySelectorVC.view.frame.height
        }
        else {
            return COMPETITION_CELL_HEIGHT
        }
    }
}


// MARK: - UITableViewDelegate
extension DiscoverVC: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        tableView.deselectRow(
            at: indexPath,
            animated: false
        )
        
        if indexPath.section == 2 {
            showCompetition(
                competition: competitions[indexPath.row]
            )
        }
    }
}


// MARK: - UITableViewDataSourcePrefetching

extension DiscoverVC: UITableViewDataSourcePrefetching {

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
