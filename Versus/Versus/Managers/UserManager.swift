//
//  UserManager.swift
//  Versus
//
//  Created by JT Smrdel on 9/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

protocol UserManagerDelegate: class {
    func userResultsUpdated(
        users: [User],
        isNewSearch: Bool
    )
    func didFailWithError(error: String)
}

enum UserSearchProperty {
    case name
    case username
}

class UserManager {
    
    private let userService = UserService.instance
    private let pendingSearchOperations = SearchOperations()
    
    private var searchText: String = ""
    private var page = 1
    private var userSearchProperty: UserSearchProperty = .name
    private var isNewSearch: Bool {
        return page == 1
    }
    
    private var fetchingInProgress = false
    private(set) var hasMoreResults = false

    private weak var delegate: UserManagerDelegate?
    
    init(delegate: UserManagerDelegate) {
        self.delegate = delegate
    }
    
    
    private func addSearchOperation() {
        
        fetchingInProgress = true
        
        let searchOperation = SearchUserOperation(
            searchData: (
                userSearchProperty: userSearchProperty,
                searchText: searchText,
                page: page
            )
        )
        
        searchOperation.completionBlock = {
            
            self.fetchingInProgress = false
            
            if searchOperation.isCancelled { return }
            
            if let responseData = searchOperation.responseData {
                
                if let error = responseData.error {
                    self.delegate?.didFailWithError(
                        error: error
                    )
                }
                else {
                    self.delegate?.userResultsUpdated(
                        users: responseData.users,
                        isNewSearch: self.isNewSearch
                    )
                    self.hasMoreResults = responseData.users.count == Config.FETCH_LIMIT
                }
            }
        }
        
        pendingSearchOperations.downloadQueue.addOperation(
            searchOperation
        )
    }
    
    
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
        page = 1
        
        guard !searchText.isEmpty else {
            return
        }
        self.searchText = searchText

        addSearchOperation()
    }
    
    
    /// Fetch more users with the existing searchText.
    func fetchMoreResults() {
        guard !fetchingInProgress else { return }
        page += 1
        addSearchOperation()
    }
}
