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
    @IBOutlet weak var leaderboardCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var competitionTableView: UITableView!
    @IBOutlet weak var competitionTableViewHeight: NSLayoutConstraint!
    
    
    private let competitionService = CompetitionService.instance
    private let leaderboardService = LeaderboardService.instance
    private let pendingImageOperations = ImageOperations()
    private let leaderboardCollectionViewSectionInsets = UIEdgeInsets(
        top: 2,
        left: 2,
        bottom: 2,
        right: 2
    )
    private let browseCategoryCollectionViewSectionInsets = UIEdgeInsets(
        top: 2,
        left: 2,
        bottom: 2,
        right: 2
    )
    private let COMPETITION_CELL_HEIGHT: CGFloat = 188
    
    
    private var searchUserVC: SearchUserVC!
    private var competitions = [Competition]()
    private var leaderboards = [Leaderboard]()
    private var selectedCategoryIndexPath: IndexPath?
    
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        getFeaturedCompetitions(categoryId: nil)
        getLeaderboards()
    }

    
    
    private func configureView() {
        
        addSearchUserViewController()
        
        searchBar.backgroundImage = UIImage()
        
        competitionTableView.register(
            UINib(nibName: COMPETITION_CELL, bundle: nil),
            forCellReuseIdentifier: COMPETITION_CELL
        )
        
        leaderboardCollectionView.register(
            UINib(nibName: LEADERBOARD_CELL, bundle: nil),
            forCellWithReuseIdentifier: LEADERBOARD_CELL
        )
        
        categoryCollectionView.register(
            UINib(nibName: DISCOVER_CATEGORY_CELL, bundle: nil),
            forCellWithReuseIdentifier: DISCOVER_CATEGORY_CELL
        )
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
    
    
    private func getFeaturedCompetitions(categoryId: Int?) {
        
        competitionService.loadFeaturedCompetitions(
            categoryId: categoryId
        ) { [weak self] (competitions, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                if let error = error {
                    self.displayMessage(message: error)
                }
                
                self.competitions = competitions
                self.competitionTableViewHeight.constant = (CGFloat(competitions.count) * self.COMPETITION_CELL_HEIGHT)
                self.competitionTableView.reloadData()
            }
        }
    }
    
    
    private func getLeaderboards() {
        
        leaderboardService.getLeaderboards { [weak self] (leaderboards, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                if let error = error {
                    self.displayMessage(message: error)
                }
                
                self.leaderboards = leaderboards.sorted(
                    by: { $0.type.id < $1.type.id }
                )
                self.leaderboardCollectionView.reloadData()
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
    
    
    private func showLeaderboard(leaderboard: Leaderboard) {
        
        let leaderboardVC = LeaderboardVC(leaderboard: leaderboard)
        leaderboardVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(
            leaderboardVC,
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
                
                self.competitionTableView.reloadRows(
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
        debugPrint("# SB Operation added")
    }
    
    
    private func suspendAllOperations() {
        pendingImageOperations.downloadQueue.isSuspended = true
    }
    
    
    private func resumeAllOperations() {
        pendingImageOperations.downloadQueue.isSuspended = false
    }
    
    
    private func loadImagesForOnscreenCells() {
        
        if let pathsArray = competitionTableView.indexPathsForVisibleRows {
            
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
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        return competitions.count
    }
    
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: COMPETITION_CELL,
            for: indexPath
        ) as! CompetitionCell
        
        let competition = competitions[indexPath.row]
        
        cell.configureCell(
            competition: competition
        )
        
//        if competition.leftEntry.imageDownloadState == .new ||
//            competition.rightEntry.imageDownloadState == .new {
//
//            startCompetitionImageDownloadFor(
//                competition: competition,
//                indexPath: indexPath
//            )
//        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return COMPETITION_CELL_HEIGHT
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
        
        showCompetition(
            competition: competitions[indexPath.row]
        )
    }
}


// MARK: - UICollectionViewDataSource
extension DiscoverVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == leaderboardCollectionView {
            return leaderboards.count
        }
        else if collectionView == categoryCollectionView {
            return CategoryCollection.instance.categories.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == leaderboardCollectionView {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LEADERBOARD_CELL,
                for: indexPath
            ) as! LeaderboardCell
            
            let leaderboard = leaderboards[indexPath.row]
            cell.configureCell(leaderboard: leaderboard)
            return cell
        }
        else if collectionView == categoryCollectionView {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DISCOVER_CATEGORY_CELL,
                for: indexPath
            ) as! DiscoverCategoryCell
            
            let category = CategoryCollection.instance.categories[indexPath.row]
            var selected = false
            
            if let categoryIndexPath = selectedCategoryIndexPath, categoryIndexPath == indexPath {
                
                selected = true
            }
            cell.configureCell(
                category: category,
                selected: selected
            )
            return cell
        }
        return UICollectionViewCell()
    }
}


// MARK: - UICollectionViewDelegate
extension DiscoverVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == leaderboardCollectionView {
            
            let leaderboard = leaderboards[indexPath.row]
            
            showLeaderboard(leaderboard: leaderboard)
        }
        else if collectionView == categoryCollectionView {
            
            let cell = collectionView.cellForItem(at: indexPath) as! DiscoverCategoryCell
            cell.toggleSelected(selected: !cell.categorySelected)
            
            if cell.categorySelected {
                
                selectedCategoryIndexPath = indexPath
                getFeaturedCompetitions(
                    categoryId: cell.category.categoryType.rawValue
                )
            }
            else {
                
                selectedCategoryIndexPath = nil
                getFeaturedCompetitions(
                    categoryId: nil
                )
            }
            collectionView.reloadData()
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension DiscoverVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == leaderboardCollectionView {
            
            let itemsPerRow: CGFloat = 3
            
            let paddingSpace = leaderboardCollectionViewSectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: collectionView.frame.height)
        }
        else if collectionView == categoryCollectionView {
            
            let itemsPerRow: CGFloat = 5.5
            
            let paddingSpace = browseCategoryCollectionViewSectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: collectionView.frame.height)
        }
        return CGSize.zero
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == leaderboardCollectionView {
            return leaderboardCollectionViewSectionInsets
        }
        else if collectionView == categoryCollectionView {
            return browseCategoryCollectionViewSectionInsets
        }
        return UIEdgeInsets.zero
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == leaderboardCollectionView {
            return leaderboardCollectionViewSectionInsets.left
        }
        else if collectionView == categoryCollectionView {
            return browseCategoryCollectionViewSectionInsets.left
        }
        return 0.0
    }
}
