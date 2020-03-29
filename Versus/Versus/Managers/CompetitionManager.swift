//
//  CompetitionManager.swift
//  Versus
//
//  Created by JT Smrdel on 6/3/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

protocol CompetitionManagerDelegate: class {
    func competitionResultsUpdated(
        competitions: [Competition],
        isNewRequest: Bool
    )
    func didFailWithError(error: String)
}

enum CompetitionQueryType {
    case featured(categoryId: Int?)
    case followedUsers(userId: Int)
    case user(userId: Int)
}

class CompetitionManager {
    
    private let competitionService = CompetitionService.instance
    
    private var queryType: CompetitionQueryType = .featured(
        categoryId: nil
    )
    private var page = 1
    private var isNewRequest: Bool {
        return page == 1
    }
    private var fetchingInProgress = false
    private(set) var hasMoreResults = false
    
    private weak var delegate: CompetitionManagerDelegate?
    
    
    init(delegate: CompetitionManagerDelegate) {
        self.delegate = delegate
    }
    
    
    private func getFeaturedCompetitions(categoryId: Int?, page: Int) {
        guard !fetchingInProgress else { return }
        fetchingInProgress = true
        
        competitionService.loadFeaturedCompetitions(
            categoryId: categoryId,
            page: page
        ) { [weak self] (competitions, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.didFailWithError(
                    error: error
                )
            }
            else {
                self.delegate?.competitionResultsUpdated(
                    competitions: competitions,
                    isNewRequest: self.isNewRequest
                )
                self.hasMoreResults = competitions.count == Config.FETCH_LIMIT
            }
            self.fetchingInProgress = false
        }
    }
    
    
    private func getFollowedUserCompetitions(userId: Int, page: Int) {
        guard !fetchingInProgress else { return }
        fetchingInProgress = true
        
        competitionService.loadFollowedUserCompetitions(
            userId: userId,
            page: page
        ) { [weak self] (competitions, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.didFailWithError(
                    error: error
                )
            }
            else {
                self.delegate?.competitionResultsUpdated(
                    competitions: competitions,
                    isNewRequest: self.isNewRequest
                )
                self.hasMoreResults = competitions.count == Config.FETCH_LIMIT
            }
            self.fetchingInProgress = false
        }
    }
    
    
    private func getUserCompetitions(userId: Int, page: Int) {
        guard !fetchingInProgress else { return }
        fetchingInProgress = true
        
        competitionService.loadUserCompetitions(
            userId: userId,
            page: page
        ) { [weak self] (competitions, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.didFailWithError(
                    error: error
                )
            }
            else {
                self.delegate?.competitionResultsUpdated(
                    competitions: competitions,
                    isNewRequest: self.isNewRequest
                )
                self.hasMoreResults = competitions.count == Config.FETCH_LIMIT
            }
            self.fetchingInProgress = false
        }
    }
    
    
    func getCompetitions(
        queryType: CompetitionQueryType
    ) {
        self.queryType = queryType
        page = 1
        
        switch queryType {
        case .featured(let categoryId):
            getFeaturedCompetitions(
                categoryId: categoryId,
                page: page
            )
            
        case .followedUsers(let userId):
            getFollowedUserCompetitions(
                userId: userId,
                page: page
            )
            
        case .user(let userId):
            getUserCompetitions(
                userId: userId,
                page: page
            )
        }
    }
    
    
    /// Fetch more competitions with the existing queryType
    func fetchMoreResults() {
        guard !fetchingInProgress else { return }
        page += 1
        
        switch queryType {
        case .featured(let categoryId):
            getFeaturedCompetitions(
                categoryId: categoryId,
                page: page
            )
            
        case .followedUsers(let userId):
            getFollowedUserCompetitions(
                userId: userId,
                page: page
            )
            
        case .user(let userId):
            getUserCompetitions(
                userId: userId,
                page: page
            )
        }
    }
}
