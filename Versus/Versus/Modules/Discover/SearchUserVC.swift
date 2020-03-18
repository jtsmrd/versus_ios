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

    
    @IBOutlet weak var userTableView: UITableView!
    
    
    private let userManager = UserManager.instance
    private let followerService = FollowerService.instance
    private let pendingImageOperations = ImageOperations()
    private let ROW_HEIGHT: CGFloat = 70.0
    private let PREFETCH_SCROLL_PERCENTAGE: CGFloat = 0.85
    
    
    private var users = [User]()
    private var delegate: SearchVCDelegate?
    private var keyboardToolbar: KeyboardToolbar!
    private var indexPathOfLastSelection: IndexPath?
    
    
    
    init(delegate: SearchVCDelegate?) {
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userTableView.register(
            UINib(nibName: SEARCH_USER_CELL, bundle: nil),
            forCellReuseIdentifier: SEARCH_USER_CELL
        )
        
        userTableView.tableFooterView = UIView()
        userManager.delegate = self
        keyboardToolbar = KeyboardToolbar(includeNavigation: false)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        indexPathOfLastSelection = nil
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
}




// MARK: - UserManagerDelegate
extension SearchUserVC: UserManagerDelegate {
    
    
    func userResultsUpdated(users: [User], isNewSearch: Bool) {
        
        if isNewSearch {
            self.users = users
        }
        else {
            self.users.append(contentsOf: users)
        }
        
        DispatchQueue.main.async {
            self.userTableView.reloadData()
        }
    }
    
    
    func didFailWithError(errorMessage: String) {
        
        displayMessage(message: errorMessage)
    }
}




// MARK: - UITableViewDataSource
extension SearchUserVC: UITableViewDataSource {
    
    /**
     Return the current count of users from UserManager.
     */
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        return users.count
    }
    
    
    /**
     Download the user image and configure the SearchUserCell.
     */
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SEARCH_USER_CELL,
            for: indexPath
        )
        
        if let searchUserCell = cell as? SearchUserCell {
            
            let user = users[indexPath.row]
            
            // Configure the cell with a user.
            //TODO
            searchUserCell.configureCell(
                user: user,
                profileImage: user.profileImageImage
            )
            
            if user.profileImageDownloadState == .new {

                if !tableView.isDragging && !tableView.isDecelerating {

                    startProfileImageDownloadFor(
                        user: user,
                        indexPath: indexPath
                    )
                }
            }
            
            // TODO: Fix only downloading images for visible cells.
//            switch user.profileImageDownloadState {
//
//            case .new:
//
//
//            case .failed, .downloaded:
//                print("Image download failed")
//            }
            
            return searchUserCell
        }
        return SearchUserCell()
    }
    
    
    /**
     Set the row height.
     */
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        return ROW_HEIGHT
    }
}




// MARK: - UITableViewDataSourcePrefetching
extension SearchUserVC: UITableViewDataSourcePrefetching {
    
    /**
    If more results exist, fetch them when the prefetch index >= the
     current user count.
     */
    func tableView(
        _ tableView: UITableView,
        prefetchRowsAt indexPaths: [IndexPath]
    ) {
        
        // No need to fetch if there are no more results
        guard userManager.hasMoreResults == true else { return }
        
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
    
    /**
     View the profile for the user selected.
     */
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        indexPathOfLastSelection = indexPath
        
        tableView.deselectRow(
            at: indexPath,
            animated: false
        )
        
        showUserProfile(indexPath: indexPath)
    }
}




// MARK: - UIScrollViewDelegate
extension SearchUserVC: UIScrollViewDelegate {
    
    // TODO: Fix
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
        
        if users.isEmpty {
            delegate?.toggleSearchView(isHidden: true)
            searchBar.text?.removeAll()
        }
    }
    
    
    func searchBarCancelButtonClicked(
        _ searchBar: UISearchBar
    ) {
        
        view.endEditing(true)
        delegate?.toggleSearchView(isHidden: true)
        searchBar.text?.removeAll()
        users.removeAll()
        userTableView.reloadData()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        
//        cancelAllPendingImageDownloads()
        
        // Remove results for new searches.
//        users.removeAll()
//        userTableView.reloadData()
        
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




// MARK: - Image Operations
extension SearchUserVC {
    
    
//    private func startProfileImageDownloadFor(
//        user: User,
//        indexPath: IndexPath
//    ) {
//        var downloadsInProgress = pendingImageOperations.downloadsInProgress
//
//        // Make sure there isn't already a download in progress.
//        guard downloadsInProgress[indexPath] == nil else { return }
//
//        let downloadOperation = DownloadUserProfileImageOperation(
//            user: user
//        )
//
//        downloadOperation.completionBlock = {
//
//            if downloadOperation.isCancelled { return }
//
//            DispatchQueue.main.async {
//                downloadsInProgress.removeValue(
//                    forKey: indexPath
//                )
//                self.userTableView.reloadRows(
//                    at: [indexPath],
//                    with: .none
//                )
//            }
//        }
//
//        // Add the operation to the collection of downloads in progress.
//        downloadsInProgress[indexPath] = downloadOperation
//
//        // Add the operation to the queue to start downloading.
//        pendingImageOperations.downloadQueue.addOperation(
//            downloadOperation
//        )
//    }
    
    
    private func startProfileImageDownloadFor(
        user: User,
        indexPath: IndexPath
    ) {
        var downloadsInProgress = pendingImageOperations.asyncDownloadsInProgress

        // Make sure there isn't already a download in progress.
        guard downloadsInProgress[indexPath] == nil else { return }

        let downloadOperation = DownloadImageOperation(entity: user)

        downloadOperation.completionBlock = {

            if downloadOperation.isCancelled { return }

            DispatchQueue.main.async {
                downloadsInProgress.removeValue(
                    forKey: indexPath
                )
                self.userTableView.reloadRows(
                    at: [indexPath],
                    with: .none
                )
            }
        }

        // Add the operation to the collection of downloads in progress.
        downloadsInProgress[indexPath] = downloadOperation

        // Add the operation to the queue to start downloading.
        pendingImageOperations.asyncDownloadQueue.addOperation(
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
        
        if let pathsArray = userTableView.indexPathsForVisibleRows {
            
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
                
                let user = users[indexPath.row]
                
                startProfileImageDownloadFor(
                    user: user,
                    indexPath: indexPath
                )
            }
        }
    }
    
    private func cancelAllPendingImageDownloads() {
        
        DispatchQueue.main.async {
            var downloadsInProgress =
                self.pendingImageOperations.downloadsInProgress
            
            let allPendingOperations = Set(
                downloadsInProgress.keys
            )
            
            for indexPath in allPendingOperations {
                
                if let pendingDownload = downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
//                downloadsInProgress.removeValue(
//                    forKey: indexPath
//                )
            }
        }
        
        
    }
}



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
