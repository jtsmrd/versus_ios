//
//  Competition.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol EnumDescription  {
    var desc: String { get }
}

enum CompetitionType: Int {
    case unknown = 0
    case image = 1
    case video = 2
    
    var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .image:
            return "image"
        case .video:
            return "video"
        }
    }
}

class Competition: Codable {
    
    private var _id: Int
    private var _active: Bool
    private var _categoryId: Int
    private var _typeId: Int
    private var _expireDate: Date
    private var _extended: Bool
    private var _featured: Bool
    private var _startDate: Date
    private var _winnerUserId: Int?
    private var _leftEntry: Entry
    private var _rightEntry: Entry
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _active = "active"
        case _categoryId = "categoryId"
        case _typeId = "typeId"
        case _expireDate = "expireDate"
        case _extended = "extended"
        case _featured = "featured"
        case _startDate = "startDate"
        case _winnerUserId = "winnerUserId"
        case _leftEntry = "leftEntry"
        case _rightEntry = "rightEntry"
    }
}

extension Competition {
    
    
    var category: Category {

        let categoryType = CategoryType(rawValue: _categoryId) ?? .unknown
        return CategoryCollection.instance.getCategory(categoryType: categoryType)
    }


    var id: Int {
        return _id
    }


    var competitionType: CompetitionType {
        return CompetitionType(rawValue: _typeId) ?? .unknown
    }


    var leftEntry: Entry {
        return _leftEntry
    }
    
    
    var rightEntry: Entry {
        return _rightEntry
    }


    var isExpired: Bool {
        return _expireDate < Date()
    }


    var secondsUntilExpire: Int {
        return Date().seconds(until: _expireDate)
    }
}
