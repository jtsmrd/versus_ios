//
//  Vote.swift
//  Versus
//
//  Created by JT Smrdel on 5/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class Vote: Codable {
    
    private var _competitionEntryId: String = ""
    private var _competitionId: String = ""
    private var _userId: String = ""
    private var _competitorTypeString: String = ""
    
    
    init(
        competitionEntryId: String,
        competitionId: String,
        userId: String,
        competitorTypeString: String
    ) {
        _competitionEntryId = competitionEntryId
        _competitionId = competitionId
        _userId = userId
        _competitorTypeString = competitorTypeString
    }
}

extension Vote {
    
    
    var competitionEntryId: String {
        return _competitionEntryId
    }
    
    
    var competitorType: CompetitorType {
        return CompetitorType(rawValue: _competitorTypeString) ?? .unknown
    }
}
