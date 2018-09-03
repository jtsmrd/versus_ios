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
    private(set) var users = [User]()
    let pendingImageOperations = ImageOperations()
    var delegate: UserManagerDelegate?
    var hasMoreResults = false
    // TODO: Fix -1: the first request returns 24 instead of 25
    var potentialUserCount: Int {
        guard users.count >= FETCH_LIMIT - 1 else {
            return users.count
        }
        return users.count + (hasMoreResults ? 1 : 0)
    }
    
    private init() { }
    
    
    /**
     
     */
    func getUserFor(indexPath: IndexPath) -> User? {
        if indexPath.row < users.count {
            return users[indexPath.row]
        }
        return nil
    }
    
    
    /**
     
     */
    func removeAllUsers() {
        users.removeAll()
        searchText = nil
        startKey = nil
        hasMoreResults = false
    }
    
    
    /**
     
     */
    func searchUsers(
        searchText: String,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
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
     
     */
    func fetchMoreResults(
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
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
 
     */
    private func searchUsers(
        searchText: String,
        startKey: [String: AWSDynamoDBAttributeValue]?,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
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
    
    
    func startProfileImageDownloadFor(user: User, indexPath: IndexPath) {
        guard pendingImageOperations.downloadsInProgress[indexPath] == nil else { return }
        
        let downloader = DownloadUserProfileImageOperation(user: user)
        downloader.completionBlock = {
            if downloader.isCancelled { return }
            DispatchQueue.main.async {
                self.pendingImageOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.delegate?.reloadCell(at: indexPath)
            }
        }
        
        pendingImageOperations.downloadsInProgress[indexPath] = downloader
        pendingImageOperations.downloadQueue.addOperation(downloader)
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
            if let _ = image {
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
