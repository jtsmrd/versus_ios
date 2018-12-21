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
}

class UserManager {
    
    static let instance = UserManager()
    private let userService = UserService.instance
    
    private let FETCH_LIMIT = 25
    private var searchText: String?
    private var startKey: [String: AWSDynamoDBAttributeValue]?
    private var fetchingInProgress = false
    private(set) var hasMoreResults = false
    private(set) var users = [User]()
    let pendingImageOperations = ImageOperations()
    var delegate: UserManagerDelegate?

    
    private init() { }
    
    
    /**
     Return a user for the specified indexPath.
     */
    func getUserFor(
        indexPath: IndexPath
    ) -> User? {
        
        guard indexPath.row < users.count else {
            return nil
        }
        return users[indexPath.row]
    }
    
    
    /**
     Clear all users, and set searchText, startKey, and hasMoreResults
     back to default values.
     */
    func removeAllUsers() {
        users.removeAll()
        searchText = nil
        startKey = nil
        hasMoreResults = false
    }
    
    
    /**
     Search for users with the given search text.
     */
    func searchUsers(
        searchText: String,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        
        // If the search text changed, it is a new search. Clear out
        // the current results.
        if self.searchText != searchText {
            users.removeAll()
        }
        self.searchText = searchText
        searchUsers(
            searchText: searchText,
            startKey: nil,
            completion: completion
        )
    }
    
    
    /**
     Used for paginating results.
     */
    func fetchMoreResults(
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        
        // If startKey or searchText is nil, it's a new search.
        guard let startKey = startKey, let searchText = searchText else {
            self.startKey = nil
            self.searchText = nil
            completion(nil)
            return
        }
        searchUsers(
            searchText: searchText,
            startKey: startKey,
            completion: completion
        )
    }
    
    
    /**
     Private function that's called by fetchMoreResults when there's a
     start key.
     */
    private func searchUsers(
        searchText: String,
        startKey: [String: AWSDynamoDBAttributeValue]?,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        
        // Return if a fetch is already in progress.
        guard !fetchingInProgress else {
            completion(nil)
            return
        }
        fetchingInProgress = true
        
        userService.searchUsers(
            queryString: searchText,
            startKey: startKey,
            fetchLimit: FETCH_LIMIT
        ) { (users, startKey, customError) in
            
            self.fetchingInProgress = false
            if let customError = customError {
                completion(customError)
                return
            }
            self.users.append(contentsOf: users)
            self.startKey = startKey
            self.hasMoreResults = startKey != nil
            completion(nil)
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
        user.getProfileImage { (image, customError) in
            
            // The image was already downloaded from a previous request
            if image != nil {
                self.user.profileImageDownloadState = .downloaded
                return
            }
            if let customError = customError {
                debugPrint(customError.message)
            }
            self.user.profileImageDownloadState = .failed
        }
        if isCancelled { return }
    }
}
