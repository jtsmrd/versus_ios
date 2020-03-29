//
//  FollowerManager.swift
//  Versus
//
//  Created by JT Smrdel on 3/29/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import Foundation

protocol FollowerManagerDelegate: class {
    func followerResultsUpdated(
        followers: [Follower],
        isNewSearch: Bool
    )
    func didFailWithError(error: String)
}

class FollowerManager {
    
    private let followerService = FollowerService.instance
    
    private var followerType: FollowerType!
    private var page = 1
    private var isNewSearch: Bool {
        return page == 1
    }
    private var fetchingInProgress = false
    private(set) var hasMoreResults = false
    
    private weak var delegate: FollowerManagerDelegate?
    
    private lazy var responseHandler: ([Follower], String?) -> () = { [weak self] (followers, error) in
        guard let self = self else { return }
        
        if let error = error {
            self.delegate?.didFailWithError(
                error: error
            )
        }
        else {
            self.delegate?.followerResultsUpdated(
                followers: followers,
                isNewSearch: self.isNewSearch
            )
            self.hasMoreResults = followers.count == Config.FETCH_LIMIT
        }
        self.fetchingInProgress = false
    }
    
    
    init(delegate: FollowerManagerDelegate) {
        self.delegate = delegate
    }
    
    
    private func getFollowers(
        userId: Int,
        page: Int
    ) {
        guard !fetchingInProgress else { return }
        fetchingInProgress = true
        
        followerService.loadFollowers(
            userId: userId,
            page: page,
            completion: responseHandler
        )
    }
    
    
    private func getFollowedUsers(
        userId: Int,
        page: Int
    ) {
        guard !fetchingInProgress else { return }
        fetchingInProgress = true
        
        followerService.loadFollowedUsers(
            userId: userId,
            page: page,
            completion: responseHandler
        )
    }
    
    
    func getFollowers(
        followerType: FollowerType
    ) {
        self.followerType = followerType
        page = 1
        
        switch followerType {
        case .follower(let userId):
            getFollowers(
                userId: userId,
                page: page
            )
            
        case .followedUser(let userId):
            getFollowedUsers(
                userId: userId,
                page: page
            )
        }
    }
    
    
    func fetchMoreResults() {
        guard !fetchingInProgress else { return }
        page += 1
        
        switch followerType {
        case .follower(let userId):
            getFollowers(
                userId: userId,
                page: page
            )
            
        case .followedUser(let userId):
            getFollowedUsers(
                userId: userId,
                page: page
            )
            
        default:
            break
        }
    }
}
