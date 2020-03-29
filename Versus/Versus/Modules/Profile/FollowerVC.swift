//
//  FollowerVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum FollowerType {
    case follower(userId: Int)
    case followedUser(userId: Int)
}

class FollowerVC: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var followerTableView: UITableView!
    
    
    private let followerService = FollowerService.instance
    private let PREFETCH_SCROLL_PERCENTAGE: CGFloat = 0.50
    
    
    private var followerManager: FollowerManager!
    private var followerType: FollowerType!
    private var followers = [Follower]()
    private var pendingImageOperations = ImageOperations()
    private var keyboardToolbar: KeyboardToolbar!
    private var indexPathOfLastSelection: IndexPath?
    private var refreshControl: UIRefreshControl!
    
    
    
    init(followerType: FollowerType) {
        super.init(nibName: nil, bundle: nil)
        
        self.followerType = followerType
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        followerManager = FollowerManager(delegate: self)
        
        followerTableView.register(
            UINib(nibName: FOLLOWER_CELL, bundle: nil),
            forCellReuseIdentifier: FOLLOWER_CELL
        )
        
        followerTableView.register(
            UINib(nibName: "NoFollowersCell", bundle: nil),
            forCellReuseIdentifier: "NoFollowersCell"
        )
        
        configureRefreshControl()
        
        switch followerType {
        case .follower:
            titleLabel.text = "Followers"
            
        case .followedUser:
            titleLabel.text = "Followed Users"
            
        default:
            break
        }
        
        keyboardToolbar = KeyboardToolbar(includeNavigation: false)
        
        getFollowers()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        indexPathOfLastSelection = nil
    }
    
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc func getFollowers() {
        
        followerManager.getFollowers(
            followerType: followerType
        )
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
            action: #selector(FollowerVC.getFollowers),
            for: .valueChanged
        )
        
        followerTableView.refreshControl = refreshControl
    }
    
    
    private func filterFollowers(filter: String) {
        
//        guard !filter.isEmpty else {
//            filteredFollowers = nil
//            followerTableView.reloadData()
//            return
//        }
//        filteredFollowers = allFollowers.filter({ $0.searchUsername.contains(filter.lowercased()) || $0.searchDisplayName.contains(filter.lowercased()) })
//        followerTableView.reloadData()
    }
    
    
    
    private func showFollowerProfileAt(indexPath: IndexPath) {
        
        var user: User!
        
        switch followerType {
        case .follower:
            user = followers[indexPath.row].user
            
        case .followedUser:
            user = followers[indexPath.row].followedUser
            
        default:
            return
        }
        
        let userVC = UserVC(
            user: user,
            delegate: self
        )
        navigationController?.pushViewController(
            userVC,
            animated: true
        )
    }
    
    
    // MARK: - Image Operations
    
    private func startUserProfileImageDownloadFor(
        user: User,
        indexPath: IndexPath
    ) {
        var downloadsInProgress = pendingImageOperations.asyncDownloadsInProgress

        // Make sure there isn't already a download in progress.
        guard downloadsInProgress[indexPath] == nil else { return }

        let downloadOperation = DownloadUserProfileImageOperation(
            user: user
        )

        downloadOperation.completionBlock = {

            if downloadOperation.isCancelled { return }

            DispatchQueue.main.async {

                downloadsInProgress.removeValue(
                    forKey: indexPath
                )

                if let followerCell = self.followerTableView.cellForRow(at: indexPath) as? FollowerCell {
                    followerCell.updateImage()
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


private extension FollowerVC {

    private func calculateIndexPathsToReload(
        from newFollowers: [Follower]
    ) -> [IndexPath] {
        
        let startIndex = followers.count - newFollowers.count
        let endIndex = startIndex + newFollowers.count
        let indexPaths = (startIndex..<endIndex).map {
            IndexPath(row: $0, section: 0)
        }
        
        return indexPaths
    }
    
    func visibleIndexPathsToReload(
        intersecting indexPaths: [IndexPath]
    ) -> [IndexPath] {
        
        let indexPathsForVisibleRows = followerTableView.indexPathsForVisibleRows ?? []
        
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        
        return Array(indexPathsIntersection)
    }
}


// MARK: - FollowerManagerDelegate

extension FollowerVC: FollowerManagerDelegate {
    
    func followerResultsUpdated(
        followers: [Follower],
        isNewSearch: Bool
    ) {
        if isNewSearch {
            self.followers = followers
        }
        else {
            self.followers.append(contentsOf: followers)
        }
        
        DispatchQueue.main.async {
            
            var newIndexPathsToReload: [IndexPath]?
            if !isNewSearch {
                newIndexPathsToReload = self.calculateIndexPathsToReload(
                    from: followers
                )
            }
                   
            guard let newIndexPaths = newIndexPathsToReload else {
                self.followerTableView.refreshControl?.endRefreshing()
                self.followerTableView.reloadData()
                return
            }
            
            self.followerTableView.beginUpdates()
            self.followerTableView.insertRows(
                at: newIndexPaths,
                with: .none
            )
            self.followerTableView.endUpdates()
        }
    }
    
    func didFailWithError(error: String) {
        DispatchQueue.main.async {
            self.displayMessage(message: error)
        }
    }
}



extension FollowerVC: UserVCDelegate {
    
    func userUpdated() {
        
        guard let indexPath = indexPathOfLastSelection else {
            return
        }
        
        followerTableView.reloadRows(
            at: [indexPath],
            with: .none
        )
    }
}



extension FollowerVC: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.inputAccessoryView = keyboardToolbar
        return true
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
//        if followers.isEmpty {
//            searchBar.text?.removeAll()
//            filteredFollowers = nil
//            followerTableView.reloadData()
//        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text?.removeAll()
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
        
//        filteredFollowers = nil
//        followerTableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFollowers(filter: searchText)
    }
}



extension FollowerVC: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if !followers.isEmpty {
            return followers.count
        }
        else {
            return 1    // No followers cell
        }
    }
    
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        if !followers.isEmpty {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FOLLOWER_CELL,
                for: indexPath
            ) as! FollowerCell
            
            let follower = followers[indexPath.row]
            
            var user: User!
            switch followerType! {
            case .follower:
                user = follower.user
                
            case .followedUser:
                user = follower.followedUser
            }
            
            cell.configureCell(
                follower: follower,
                user: user
            )
            
            if user.profileImageDownloadState == .new {
                startUserProfileImageDownloadFor(
                    user: user,
                    indexPath: indexPath
                )
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "NoFollowersCell",
                for: indexPath
            )
            return cell
        }
    }
    
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if !followers.isEmpty {
            return 70
        }
        else {
            return tableView.frame.height    // No followers cell
        }
    }
}


extension FollowerVC: UITableViewDataSourcePrefetching {
    
    func tableView(
        _ tableView: UITableView,
        prefetchRowsAt indexPaths: [IndexPath]
    ) {
        // No need to fetch if there are no more results
        guard followerManager.hasMoreResults else { return }
        
        // Get the row number of the last visible row
        guard let maxVisibleRowNumber =
            tableView.indexPathsForVisibleRows?.max()?.row else { return }
        
        // Calculate the percentage of total rows that are scolled to
        let scrollPercentage = CGFloat(maxVisibleRowNumber) / CGFloat(followers.count)
        
        // Only prefetch when the scrolled percentage is >= 85%
        guard scrollPercentage >= PREFETCH_SCROLL_PERCENTAGE else { return }
        
        followerManager.fetchMoreResults()
    }
}


extension FollowerVC: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        indexPathOfLastSelection = indexPath
        
        tableView.deselectRow(
            at: indexPath,
            animated: false
        )
        
        showFollowerProfileAt(indexPath: indexPath)
    }
}
