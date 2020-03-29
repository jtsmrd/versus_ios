//
//  SearchUserVC.swift
//  Versus
//
//  Created by JT Smrdel on 9/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit


protocol SearchVCDelegate {
    func toggleSearchView(isHidden hidden: Bool)
}

class SearchUserVC: UIViewController {

    enum SearchState {
        case newSearch
        case hasResults
        case noResults
    }
    
    @IBOutlet weak var userTableView: UITableView!
    
    private let followerService = FollowerService.instance
    private let pendingImageOperations = ImageOperations()
    private let PREFETCH_SCROLL_PERCENTAGE: CGFloat = 0.50
    private let SEARCH_RESULT_ROW_HEIGHT: CGFloat = 70.0
    
    private var userManager: UserManager!
    private var users = [User]()
    private var delegate: SearchVCDelegate?
    private var keyboardToolbar: KeyboardToolbar!
    private var indexPathOfLastSelection: IndexPath?
    private var searchText: String = ""
    
    
    
    init(delegate: SearchVCDelegate?) {
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userManager = UserManager(delegate: self)
        
        registerCells()
        
        userTableView.tableFooterView = UIView()
        
        keyboardToolbar = KeyboardToolbar(includeNavigation: false)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        indexPathOfLastSelection = nil
    }
    
    
    
    private func registerCells() {
        
        userTableView.register(
            UINib(nibName: SEARCH_USER_CELL, bundle: nil),
            forCellReuseIdentifier: SEARCH_USER_CELL
        )
        
        userTableView.register(
            UINib(nibName: NEW_SEARCH_INFO_CELL, bundle: nil),
            forCellReuseIdentifier: NEW_SEARCH_INFO_CELL
        )
        
        userTableView.register(
            UINib(nibName: NO_USER_SEARCH_RESULTS_CELL, bundle: nil),
            forCellReuseIdentifier: NO_USER_SEARCH_RESULTS_CELL
        )
    }
    
    
    private func getSearchState() -> SearchState {
        
        if searchText.isEmpty {
            return .newSearch
        }
        else {
            if users.isEmpty {
                return .noResults
            }
            else {
                return .hasResults
            }
        }
    }
    
    
    private func getSearchResultCell(
        indexPath: IndexPath
    ) -> SearchUserCell {
        
        let cell = userTableView.dequeueReusableCell(
            withIdentifier: SEARCH_USER_CELL,
            for: indexPath
        ) as! SearchUserCell
        
        let user = users[indexPath.row]
        cell.configureCell(
            user: user
        )
        
        if user.profileImageDownloadState == .new {
            startProfileImageDownloadFor(
                user: user,
                indexPath: indexPath
            )
        }
        return cell
    }
    
    
    private func getSearchInfoCell(
        indexPath: IndexPath
    ) -> NewSearchInfoCell {
        
        let cell = userTableView.dequeueReusableCell(
            withIdentifier: NEW_SEARCH_INFO_CELL,
            for: indexPath
        ) as! NewSearchInfoCell
        return cell
    }
    
    
    private func getNoUserSearchResultsCell(
        indexPath: IndexPath
    ) -> NoUserSearchResultsCell {
        
        let cell = userTableView.dequeueReusableCell(
            withIdentifier: NO_USER_SEARCH_RESULTS_CELL,
            for: indexPath
        ) as! NoUserSearchResultsCell
        cell.configureCell(searchText: searchText)
        return cell
    }
    
    
    private func showUserProfile(indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        
        let userVC = UserVC(
            user: user,
            delegate: self
        )
        userVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(
            userVC,
            animated: true
        )
    }
    
    
    // MARK: - Image Operations
    
    private func startProfileImageDownloadFor(
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
                
                if let searchUserCell = self.userTableView.cellForRow(at: indexPath) as? SearchUserCell {
                    searchUserCell.updateProfileImage()
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
    
    
    private func cancelAllPendingImageDownloads() {
            
        var downloadsInProgress =
            self.pendingImageOperations.downloadsInProgress
        
        let allPendingOperations = Set(
            downloadsInProgress.keys
        )
        
        for indexPath in allPendingOperations {
            if let pendingDownload = downloadsInProgress[indexPath] {
                pendingDownload.cancel()
            }
            downloadsInProgress.removeValue(
                forKey: indexPath
            )
        }
    }
}


private extension SearchUserVC {

    private func calculateIndexPathsToReload(
        from newUsers: [User]
    ) -> [IndexPath] {
        
        let startIndex = users.count - newUsers.count
        let endIndex = startIndex + newUsers.count
        let indexPaths = (startIndex..<endIndex).map {
            IndexPath(row: $0, section: 0)
        }
        
        return indexPaths
    }
    
    func visibleIndexPathsToReload(
        intersecting indexPaths: [IndexPath]
    ) -> [IndexPath] {
        
        let indexPathsForVisibleRows = userTableView.indexPathsForVisibleRows ?? []
        
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        
        return Array(indexPathsIntersection)
    }
}


// MARK: - UserManagerDelegate
extension SearchUserVC: UserManagerDelegate {
    
    func userResultsUpdated(
        users: [User],
        isNewSearch: Bool
    ) {
        if isNewSearch {
            self.users = users
        }
        else {
            self.users.append(contentsOf: users)
        }
        
        DispatchQueue.main.async {
            
            var newIndexPathsToReload: [IndexPath]?
            if !isNewSearch {
                newIndexPathsToReload = self.calculateIndexPathsToReload(
                    from: users
                )
            }
            
            guard let newIndexPaths = newIndexPathsToReload else {
                self.userTableView.reloadData()
                return
            }
            
            self.userTableView.beginUpdates()
            self.userTableView.insertRows(
                at: newIndexPaths,
                with: .none
            )
            self.userTableView.endUpdates()
        }
    }
    
    func didFailWithError(error: String) {
        DispatchQueue.main.async {
            self.displayMessage(message: error)
        }
    }
}




// MARK: - UITableViewDataSource
extension SearchUserVC: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        let searchState = getSearchState()
        
        switch searchState {
            
        case .newSearch, .noResults:
            userTableView.isScrollEnabled = false
            return 1
            
        case .hasResults:
            userTableView.isScrollEnabled = true
            return users.count
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let searchState = getSearchState()
        
        switch searchState {
            
        case .newSearch:
            return getSearchInfoCell(indexPath: indexPath)
            
        case .noResults:
            return getNoUserSearchResultsCell(indexPath: indexPath)
            
        case .hasResults:
            return getSearchResultCell(indexPath: indexPath)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        let searchState = getSearchState()
        
        switch searchState {
            
        case .newSearch, .noResults:
            return userTableView.frame.height
            
        case .hasResults:
            return SEARCH_RESULT_ROW_HEIGHT
        }
    }
}




// MARK: - UITableViewDataSourcePrefetching
extension SearchUserVC: UITableViewDataSourcePrefetching {
    
    func tableView(
        _ tableView: UITableView,
        prefetchRowsAt indexPaths: [IndexPath]
    ) {
        // No need to fetch if there are no more results
        guard userManager.hasMoreResults else { return }
        
        // Get the row number of the last visible row
        guard let maxVisibleRowNumber =
            tableView.indexPathsForVisibleRows?.max()?.row else { return }
        
        // Calculate the percentage of total rows that are scolled to
        let scrollPercentage = CGFloat(maxVisibleRowNumber) / CGFloat(users.count)
        
        // Only prefetch when the scrolled percentage is >= 85%
        guard scrollPercentage >= PREFETCH_SCROLL_PERCENTAGE else { return }
        
        userManager.fetchMoreResults()
    }
}


// MARK: - UITableViewDelegate
extension SearchUserVC: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        indexPathOfLastSelection = indexPath
        
        tableView.deselectRow(
            at: indexPath,
            animated: false
        )
        
        if getSearchState() == .hasResults {
            showUserProfile(indexPath: indexPath)
        }
    }
}


// MARK: - UISearchBarDelegate
extension SearchUserVC: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(
        _ searchBar: UISearchBar
    ) -> Bool {
        searchBar.inputAccessoryView = keyboardToolbar
        return true
    }
    
    func searchBarTextDidBeginEditing(
        _ searchBar: UISearchBar
    ) {
        delegate?.toggleSearchView(isHidden: false)
        searchBar.setShowsCancelButton(
            true,
            animated: true
        )
    }
    
    func searchBarTextDidEndEditing(
        _ searchBar: UISearchBar
    ) {
        searchBar.setShowsCancelButton(
            false,
            animated: true
        )
    }
    
    func searchBarCancelButtonClicked(
        _ searchBar: UISearchBar
    ) {
        view.endEditing(true)
        delegate?.toggleSearchView(isHidden: true)
        searchBar.text?.removeAll()
        searchText = ""
        users.removeAll()
        userTableView.reloadData()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        self.searchText = searchText
        cancelAllPendingImageDownloads()
        
        // Remove results if search text is empty
        if searchText.isEmpty {
            users.removeAll()
            userTableView.reloadData()
        }
        
        // User is searching by username, wait for more characters.
        guard searchText != "@" else {
            return
        }
        
        let userSearchProperty: UserSearchProperty = searchText.contains("@") ? .username : .name
        
        userManager.searchUsers(
            searchText: searchText,
            userSearchProperty: userSearchProperty
        )
    }
}


// MARK: - Image UserVCDelegate
extension SearchUserVC: UserVCDelegate {
    
    func userUpdated() {
        
        guard let indexPath = indexPathOfLastSelection else {
            return
        }
        
        userTableView.reloadRows(
            at: [indexPath],
            with: .none
        )
    }
}
