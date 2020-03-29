//
//  SearchOperations.swift
//  Versus
//
//  Created by JT Smrdel on 3/28/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import Foundation

class SearchOperations {
    
    lazy var downloadsInProgress: [SearchUserOperation] = []
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Async Search Queue"
        queue.qualityOfService = QualityOfService.userInitiated
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}


class SearchUserOperation: AsyncOperation {
    
    private let userService = UserService.instance
    
    let searchData: (
        userSearchProperty: UserSearchProperty,
        searchText: String,
        page: Int
    )
    
    var responseData: (users: [User], error: String?)?
    
    init(
        searchData: (
            userSearchProperty: UserSearchProperty,
            searchText: String,
            page: Int
        )
    ) {
        self.searchData = searchData
    }
    
    override func execute() {
        
        if isCancelled { return }
        
        switch searchData.userSearchProperty {
        case .name:
            searchByName(
                name: searchData.searchText,
                page: searchData.page
            )
            
        case .username:
            searchByUsername(
                username: searchData.searchText,
                page: searchData.page
            )
        }
    }
    
    private func searchByName(name: String, page: Int) {
        
        userService.searchByName(
            name: name,
            page: page
        ) { [weak self] (users, error) in
            guard let self = self else { return }
            
            self.responseData = (users, error)
            self.isFinished = true
        }
    }
    
    private func searchByUsername(username: String, page: Int) {
        
        let searchUsername = String(
            username.suffix(username.count - 1)
        )
        
        userService.searchByUsername(
            username: searchUsername,
            page: page
        ) { [weak self] (users, error) in
            guard let self = self else { return }
            
            self.responseData = (users, error)
            self.isFinished = true
        }
    }
}
