//
//  Entry.swift
//  Versus
//
//  Created by JT Smrdel on 4/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class Entry: Codable {
    
    private var _caption: String?
    private var _categoryId: Int
    private var _createDate: Date
    private var _featured: Bool
    private var _id: Int
    private var _matchDate: Date?
    private var _mediaId: String
    private var _rankId: Int
    private var _typeId: Int
    private var _updateDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case _caption = "caption"
        case _categoryId = "categoryId"
        case _createDate = "createDate"
        case _featured = "featured"
        case _id = "id"
        case _matchDate = "matchDate"
        case _mediaId = "mediaId"
        case _rankId = "rankId"
        case _typeId = "typeId"
        case _updateDate = "updateDate"
    }
}

extension Entry {
    
    
    var category: Category {
        return CategoryCollection.instance.getCategory(categoryType: categoryType)
    }
    
    
    var categoryType: CategoryType {
        return CategoryType(rawValue: typeId) ?? .unknown
    }
    
    
    var competitionTypeName: String {
        return (CompetitionType(rawValue: typeId) ?? .unknown).description
    }
    
    
    var createDate: Date {
        return _createDate
    }
    
    
    var featured: Bool {
        return _featured
    }
    
    
    var isMatched: Bool {
        return _matchDate != nil
    }
    
    
    var matchDate: Date? {
        return _matchDate
    }
    
    
    var mediaId: String {
        return _mediaId
    }
    
    
    var rank: Rank {
        return RankCollection.instance.rankFor(rankId: _rankId)
    }
    
    
    var typeId: Int {
        return _typeId
    }
}
