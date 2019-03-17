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

    
    @IBOutlet weak var searchUserTableView: UITableView!
    
    
    private let userManager = UserManager.instance
    private let ROW_HEIGHT: CGFloat = 70.0
    private let PREFETCH_SCROLL_PERCENTAGE: CGFloat = 0.85
    
    private var users = [User]()
    
    var delegate: SearchVCDelegate?
    var keyboardToolbar: KeyboardToolbar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userManager.delegate = self
        keyboardToolbar = KeyboardToolbar(includeNavigation: false)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchUserTableView.reloadData()
    }
    
    
    private func suspendAllOperations() {
//        userManager.pendingImageOperations.downloadQueue.isSuspended = true
    }
    
    
    private func resumeAllOperations() {
//        userManager.pendingImageOperations.downloadQueue.isSuspended = false
    }
    
    
    private func loadImagesForOnscreenCells() {
//        if let pathsArray = searchUserTableView.indexPathsForVisibleRows {
//
//            var downloadsInProgress =
//                userManager.pendingImageOperations.downloadsInProgress
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
//
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
//                let user = userManager.users[indexPath.row]
//                userManager.startProfileImageDownloadFor(
//                    user: user,
//                    indexPath: indexPath
//                )
//            }
//        }
    }
    
    
    private func showUserProfile(user: User) {
        
        let userVC = UserVC(user: user)
        navigationController?.pushViewController(userVC, animated: true)
    }
}

extension SearchUserVC: UserManagerDelegate {
    
    
    func userResultsUpdated(users: [User]) {
        self.users.append(contentsOf: users)
        
        DispatchQueue.main.async {
            self.searchUserTableView.reloadData()
        }
    }
    
    
    func didFailWithError(errorMessage: String) {
        displayMessage(message: errorMessage)
    }
    
    
    /**
     Called after image is downloaded for the user at the specified index.
     */
    func reloadCell(
        at indexPath: IndexPath
    ) {
        DispatchQueue.main.async {
            self.searchUserTableView.reloadRows(
                at: [indexPath],
                with: .fade
            )
        }
    }
}

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
        
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: SEARCH_USER_CELL,
            for: indexPath
        ) as? SearchUserCell {
            
            let user = users[indexPath.row]
            
            // TODO: Fix only downloading images for visible cells.
//            switch user.profileImageDownloadState {
//            case .downloaded, .new:
//                if !tableView.isDragging && !tableView.isDecelerating {
//                    userManager.startProfileImageDownloadFor(
//                        user: user,
//                        indexPath: indexPath
//                    )
//                }
//            case .failed:
//                print("Image download failed")
//            }
            
            // Configure the cell with a user.
            cell.configureCell(user: user)
            return cell
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

extension SearchUserVC: UITableViewDelegate {
    
    /**
     View the profile for the user selected.
     */
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(
            at: indexPath,
            animated: false
        )
        
        let user = users[indexPath.row]
        showUserProfile(user: user)
    }
}

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
        searchBar.setShowsCancelButton(false, animated: true)
        
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
        searchUserTableView.reloadData()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        
        // Remove results for new searches.
        users.removeAll()
        searchUserTableView.reloadData()
        
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
