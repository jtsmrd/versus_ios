//
//  Entry.swift
//  Versus
//
//  Created by JT Smrdel on 4/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

enum EntryType: String {
    case left
    case right
}

class Entry: Codable {
    
    private var _id: Int
    private var _caption: String?
    private var _categoryId: Int?
    private var _typeId: Int?
    private var _createDate: Date?
    private var _featured: Bool?
    private var _matchDate: Date?
    private var _mediaId: String
    private var _rankId: Int?
    private var _updateDate: Date?
    private var _user: User?
    private var _voteCount: Int?
    
    var imageDownloadState: ImageDownloadState = .new
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _caption = "caption"
        case _categoryId = "categoryId"
        case _typeId = "typeId"
        case _createDate = "createDate"
        case _featured = "featured"
        case _matchDate = "matchDate"
        case _mediaId = "mediaId"
        case _rankId = "rankId"
        case _updateDate = "updateDate"
        case _user = "user"
        case _voteCount = "voteCount"
    }
}

extension Entry {
    
    
    var id: Int {
        return _id
    }
    
    var categoryId: Int {
        return _categoryId ?? 0
    }
    
    var category: Category {
        return CategoryCollection.instance.getCategory(categoryType: categoryType)
    }
    
    
    var categoryType: CategoryType {
        return CategoryType(rawValue: categoryId) ?? .unknown
    }
    
    
    var competitionTypeName: String {
        return (CompetitionType(rawValue: typeId) ?? .unknown).description
    }
    
    
    var competitionType: CompetitionType {
        return CompetitionType(rawValue: typeId) ?? .unknown
    }
    
    
    var createDate: Date {
        return _createDate ?? Date()
    }
    
    
    var featured: Bool {
        return _featured ?? false
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
        return Rank(rankId: _rankId)
    }
    
    
    var typeId: Int {
        return _typeId ?? 0
    }
    
    
    var user: User {
        return _user ?? User()
    }
    
    var voteCount: Int {
        return _voteCount ?? 0
    }
}




extension Entry: Equatable {
    
    
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.id == rhs.id
    }
}
