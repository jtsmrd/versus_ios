//
//  UserManager.swift
//  Versus
//
//  Created by JT Smrdel on 9/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB

protocol UserManagerDelegate {
    func reloadCell(at indexPath: IndexPath)
    func userResultsUpdated(users: [User])
    func didFailWithError(errorMessage: String)
}

enum UserSearchProperty {
    case name
    case username
}

class UserManager {
    
    static let instance = UserManager()
    private let userService = UserService.instance
    private let pendingImageOperations = ImageOperations()
    private let FETCH_LIMIT = 25
    
    private var searchText: String = ""
    private var page: Int = 0
    private var userSearchProperty: UserSearchProperty = .name
    private var fetchingInProgress = false
    
    private(set) var hasMoreResults = false
    
    var delegate: UserManagerDelegate?

    
    private init() { }
    
    
    
    
    /// Search users by name or username.
    ///
    /// - Parameters:
    ///   - searchText: The text to seach with.
    ///   - userSearchProperty: The property of the user to search on.
    func searchUsers(
        searchText: String,
        userSearchProperty: UserSearchProperty
    ) {
        
        self.userSearchProperty = userSearchProperty
        page = 0
        
        guard !searchText.isEmpty else {
            return
        }
        
        
        switch userSearchProperty {
        case .name:
            
            self.searchText = searchText
            
            searchByName(
                name: searchText,
                page: page
            )
            
        case .username:
            
            // Remove @
            let username = String(searchText.suffix(searchText.count - 1))
            self.searchText = username
            
            searchByUsername(
                username: username,
                page: page
            )
        }
    }
    
    
    
    /// Fetch more users with the existing searchText.
    func fetchMoreResults() {
        
        page += 1
        
        switch userSearchProperty {
        case .name:
            searchByName(name: searchText, page: page)
            
        case .username:
            searchByUsername(username: searchText, page: page)
        }
    }
    
    
    
    /// Search users by name.
    ///
    /// - Parameter name: Name of user
    private func searchByName(name: String, page: Int) {
        
        userService.searchByName(
            name: name
        ) { [weak self] (users, errorMessage) in
            
            if let errorMessage = errorMessage {
                self?.delegate?.didFailWithError(errorMessage: errorMessage)
                return
            }
            
            guard let users = users else {
                self?.delegate?.didFailWithError(errorMessage: "Unable to load users")
                return
            }
            
            self?.delegate?.userResultsUpdated(users: users)
        }
    }
    
    
    
    /// Search users by username
    ///
    /// - Parameter username: Username of user
    private func searchByUsername(username: String, page: Int) {
        
        userService.searchByUsername(
            username: username
        ) { [weak self] (users, errorMessage) in
            
            if let errorMessage = errorMessage {
                self?.delegate?.didFailWithError(errorMessage: errorMessage)
                return
            }
            
            guard let users = users else {
                self?.delegate?.didFailWithError(errorMessage: "Unable to load users")
                return
            }
            
            self?.delegate?.userResultsUpdated(users: users)
        }
    }
    
    
    /**
     Download the profile image for the user at the specified index.
    */
    func startProfileImageDownloadFor(
        user: User,
        indexPath: IndexPath
    ) {
        var downloadsInProgress = pendingImageOperations.downloadsInProgress
        
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
                self.delegate?.reloadCell(at: indexPath)
            }
        }
        
        // Add the operation to the collection of downloads in progress.
        downloadsInProgress[indexPath] = downloadOperation
        
        // Add the operation to the queue to start downloading.
        pendingImageOperations.downloadQueue.addOperation(
            downloadOperation
        )
    }
}

class DownloadUserProfileImageOperation: Operation {
    
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    override func main() {
        if isCancelled { return }
        //TODO
//        user.getProfileImage { (image, customError) in
//
//            // The image was already downloaded from a previous request
//            if image != nil {
//                self.user.profileImageDownloadState = .downloaded
//                return
//            }
//            if let customError = customError {
//                debugPrint(customError.message)
//            }
//            self.user.profileImageDownloadState = .failed
//        }
        if isCancelled { return }
    }
}
