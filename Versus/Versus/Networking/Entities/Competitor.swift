//
//  Competitor.swift
//  Versus
//
//  Created by JT Smrdel on 8/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

enum CompetitorType: String {
    case first
    case second
    case unknown
}

class Competitor: Codable {
    
    private var _caption: String?
    private var _commentCount: Int = 0
    private var _competitionEntryId: String = ""
    private var _competitionId: String = ""
    private var _competitionTypeId: Int = 0
    private var _competitorTypeString: String = ""
    private var _mediaId: String = ""
    private var _userId: String = ""
    private var _username: String = ""
    private var _userRankId: Int = 0
    private var _voteCount: Int = 0
    
    
//    init(
//        competitorTypeString: String,
//        caption: String,
//        commentCount: Int,
//        competitionId: String,
//        competitionEntryId: String,
//        competitionTypeId: Int,
//        mediaId: String,
//        userId: String,
//        username: String,
//        userRankId: Int,
//        voteCount: Int
//    ) {
//        _competitorTypeString = competitorTypeString
//        _caption = caption
//        _commentCount = commentCount
//        _competitionId = competitionId
//        _competitionEntryId = competitionEntryId
//        _competitionTypeId = competitionTypeId
//        _mediaId = mediaId
//        _userId = userId
//        _username = username
//        _userRankId = userRankId
//        _voteCount = voteCount
//    }
}

extension Competitor {
    
    
    var commentCount: Int {
        return _commentCount
    }
    
    
    var competitionEntryId: String {
        return _competitionEntryId
    }
    
    
    var competitionType: CompetitionType {
        return CompetitionType(rawValue: _competitionTypeId) ?? .unknown
    }
    
    
    var competitorType: CompetitorType {
        return CompetitorType(rawValue: _competitorTypeString) ?? .unknown
    }
    
    
    var mediaId: String {
        return _mediaId
    }
    
    
    var rank: Rank {
        return RankCollection.instance.rankFor(rankId: _userRankId)
    }
    
    
    var userId: String {
        return _userId
    }
    
    
    var username: String {
        return _username
    }
    
    
    var voteCount: Int {
        return _voteCount
    }
}

extension Competitor: Equatable {
    
    static func == (lhs: Competitor, rhs: Competitor) -> Bool {
        return lhs._userId == rhs._userId
    }
}
