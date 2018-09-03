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

    private let userManager = UserManager.instance
    
    @IBOutlet weak var searchUserTableView: UITableView!
    
    var delegate: SearchVCDelegate?
    var keyboardToolbar: KeyboardToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userManager.delegate = self
        keyboardToolbar = KeyboardToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50), includeNavigation: false)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchUserTableView.reloadData()
    }
    
    
    private func suspendAllOperations() {
        userManager.pendingImageOperations.downloadQueue.isSuspended = true
    }
    
    
    private func resumeAllOperations() {
        userManager.pendingImageOperations.downloadQueue.isSuspended = false
    }
    
    
    private func loadImagesForOnscreenCells() {
        if let pathsArray = searchUserTableView.indexPathsForVisibleRows {
            let allPendingOperations = Set(userManager.pendingImageOperations.downloadsInProgress.keys)
            var toBeCancelled = allPendingOperations
            
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtract(visiblePaths)
            
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            for indexPath in toBeCancelled {
                if let pendingDownload = userManager.pendingImageOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                userManager.pendingImageOperations.downloadsInProgress.removeValue(forKey: indexPath)
            }
            
            for indexPath in toBeStarted {
                let user = userManager.users[indexPath.row]
                userManager.startProfileImageDownloadFor(user: user, indexPath: indexPath)
            }
        }
    }
}

extension SearchUserVC: UserManagerDelegate {
    
    /**
 
     */
    func reloadCell(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.searchUserTableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}

extension SearchUserVC: UITableViewDataSource {
    
    /**
 
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userManager.potentialUserCount
    }
    
    
    /**
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SEARCH_USER_CELL, for: indexPath) as? SearchUserCell {
            guard let user = userManager.getUserFor(indexPath: indexPath) else {
                return cell
            }
            
//            switch user.profileImageDownloadState {
//            case .downloaded, .new:
//                if !tableView.isDragging && !tableView.isDecelerating {
//                    userManager.startProfileImageDownloadFor(user: user, indexPath: indexPath)
//                }
//            case .failed:
//                print("Image download failed")
//            }
            
            cell.configureCell(user: user)
            return cell
        }
        return SearchUserCell()
    }
    
    
    /**
     
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension SearchUserVC: UITableViewDataSourcePrefetching {
    
    /**
        If more results exist, fetch them when the prefetch index >= the current user count
     */
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let maxIndex = indexPaths.max(), maxIndex.row >= userManager.users.count else { return }
        if userManager.hasMoreResults {
            userManager.fetchMoreResults { (customError) in
                DispatchQueue.main.async {
                    if let customError = customError {
                        debugPrint(customError.message)
                        return
                    }
                    self.searchUserTableView.reloadData()
                }
            }
        }
    }
}

extension SearchUserVC: UITableViewDelegate {
    
    /**
     
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let profileVC = UIStoryboard(name: PROFILE, bundle: nil).instantiateViewController(withIdentifier: PROFILE_VC) as? ProfileVC {
            profileVC.initData(userId: userManager.users[indexPath.row].userId)
            profileVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}

extension SearchUserVC: UIScrollViewDelegate {
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        suspendAllOperations()
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
//            loadImagesForOnscreenCells()
//            resumeAllOperations()
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        loadImagesForOnscreenCells()
//        resumeAllOperations()
    }
}

extension SearchUserVC: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.inputAccessoryView = keyboardToolbar
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.toggleSearchView(isHidden: false)
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
        if userManager.users.isEmpty {
            delegate?.toggleSearchView(isHidden: true)
            searchBar.text?.removeAll()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        delegate?.toggleSearchView(isHidden: true)
        searchBar.text?.removeAll()
        userManager.removeAllUsers()
        searchUserTableView.reloadData()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else {
            userManager.removeAllUsers()
            searchUserTableView.reloadData()
            return
        }
        userManager.searchUsers(
            searchText: searchText
        ) { (customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    debugPrint(customError.message)
                    return
                }
                self.searchUserTableView.reloadData()
            }
        }
    }
}
