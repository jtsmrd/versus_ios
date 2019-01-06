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
    
    private var _categoryTypeId: Int = 0
    private var _competitionId: String = ""
    private var _competitionTypeId: Int = 0
    private var _expireDateString: String = ""
    private var _firstCompetitor: Competitor!
    private var _isActiveInt: Int = 0
    private var _isFeaturedInt: Int = 0
    private var _secondCompetitor: Competitor!
    private var _startDateString: String = ""
    private var _isExtendedInt: Int = 0
    private var _winnerUserId: String = ""
}

extension Competition {
    
    
    var category: Category {
        
        let categoryType = CategoryType(rawValue: _categoryTypeId) ?? .unknown
        return CategoryCollection.instance.getCategory(categoryType: categoryType)
    }
    
    
    var competitionId: String {
        return _competitionId
    }
    
    
    var competitionType: CompetitionType {
        return CompetitionType(rawValue: _competitionTypeId) ?? .unknown
    }
    
    
    var firstCompetitor: Competitor {
        return _firstCompetitor
    }
    
    
    var isExpired: Bool {
        
        let expireDate = _expireDateString.toISO8601Date
        return expireDate < Date()
    }
    
    
    var secondCompetitor: Competitor {
        return _secondCompetitor
    }
    
    
    var secondsUntilExpire: Int? {
        
        let expireDate = _expireDateString.toISO8601Date
        return Date().seconds(until: expireDate)
    }
}
