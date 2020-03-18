//
//  UserManager.swift
//  Versus
//
//  Created by JT Smrdel on 9/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

protocol UserManagerDelegate {
    func userResultsUpdated(users: [User], isNewSearch: Bool)
    func didFailWithError(errorMessage: String)
}

enum UserSearchProperty {
    case name
    case username
}

class UserManager {
    
    static let instance = UserManager()
    private let userService = UserService.instance
    private let FETCH_LIMIT = 25
    
    private var searchText: String = ""
    private var page: Int = 0
    private var userSearchProperty: UserSearchProperty = .name
    private var isNewSearch: Bool {
        return page == 0
    }
    
    var delegate: UserManagerDelegate?
    private(set) var hasMoreResults = false

    
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
            guard let self = self else { return }
            
            if let errorMessage = errorMessage {
                self.delegate?.didFailWithError(
                    errorMessage: errorMessage
                )
            }
            else if let users = users {
                self.delegate?.userResultsUpdated(
                    users: users,
                    isNewSearch: self.isNewSearch
                )
            }
            else {
                self.delegate?.didFailWithError(
                    errorMessage: "Unable to load users"
                )
            }
        }
    }
    
    
    
    /// Search users by username
    ///
    /// - Parameter username: Username of user
    private func searchByUsername(username: String, page: Int) {
        
        userService.searchByUsername(
            username: username
        ) { [weak self] (users, errorMessage) in
            guard let self = self else { return }
            
            if let errorMessage = errorMessage {
                self.delegate?.didFailWithError(
                    errorMessage: errorMessage
                )
            }
            else if let users = users {
                self.delegate?.userResultsUpdated(
                    users: users,
                    isNewSearch: self.isNewSearch
                )
            }
            else {
                self.delegate?.didFailWithError(
                    errorMessage: "Unable to load users"
                )
            }
        }
    }
}
