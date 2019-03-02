//
//  CompetitionEntry.swift
//  Versus
//
//  Created by JT Smrdel on 4/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class CompetitionEntry: Codable {
    
    private var _caption: String?
    private var _categoryTypeId: Int = 0
    private var _competitionEntryId: Int = 0
    private var _competitionTypeId: Int = 0
    private var _createDateString: String = ""
    private var _displayName: String = ""
    private var _isFeaturedInt: Int = 0
    private var _isMatchedInt: Int = 0
    private var _matchDateString: String?
    private var _mediaId: String = ""
    private var _rankId: Int = 0
    private var _userId: String = ""
    private var _username: String = ""
    
    
    init(
        caption: String?,
        categoryTypeId: Int,
        competitionTypeId: Int,
        displayName: String,
        isFeatured: Bool,
        mediaId: String,
        rankId: Int,
        userId: String,
        username: String
    ) {
        _caption = caption
        _categoryTypeId = categoryTypeId
        _competitionTypeId = competitionTypeId
        _displayName = displayName
        _isFeaturedInt = Int(truncating: isFeatured as NSNumber)
        _mediaId = mediaId
        _rankId = rankId
        _userId = userId
        _username = username
    }
    
    enum CodingKeys: String, CodingKey {
        case _caption = "caption"
        case _categoryTypeId = "categoryTypeId"
        case _competitionEntryId = "competitionEntryId"
        case _competitionTypeId = "competitionTypeId"
        case _createDateString = "createDateString"
        case _displayName = "displayName"
        case _isFeaturedInt = "isFeaturedInt"
        case _isMatchedInt = "isMatchedInt"
        case _matchDateString = "matchDateString"
        case _mediaId = "mediaId"
        case _rankId = "rankId"
        case _userId = "userId"
        case _username = "username"
    }
}

extension CompetitionEntry {
    
    
    var isMatched: Bool {
        return Bool(truncating: _isMatchedInt as NSNumber)
    }
    
    
    var categoryType: CategoryType {
        return CategoryType(rawValue: _categoryTypeId) ?? .unknown
    }
    
    
    var category: Category {
        return CategoryCollection.instance.getCategory(categoryType: categoryType)
    }
    
    
    var competitionTypeName: String {
        return (CompetitionType(rawValue: _competitionTypeId) ?? .unknown).description
    }
    
    
    var createDate: Date {
        return _createDateString.toISO8601Date
    }
    
    
    var matchDate: Date? {
        
        guard let matchDateString = _matchDateString else {
            return nil
        }
        return matchDateString.toISO8601Date
    }
    
    
    var isFeatured: Bool {
        return Bool(truncating: _isFeaturedInt as NSNumber)
    }
    
    
    var rank: Rank {
        return RankCollection.instance.rankFor(rankId: _rankId)
    }
}
