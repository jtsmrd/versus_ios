//
//  Vote.swift
//  Versus
//
//  Created by JT Smrdel on 5/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

class Vote: Codable {
    
    private var _id: Int
    private var _competition: String
    private var _entry: String
    private var _user: String
    private var _createDate: Date
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _competition = "competition"
        case _entry = "entry"
        case _user = "user"
        case _createDate = "createDate"
    }
}

extension Vote {
        
    var id: Int {
        return _id
    }
    
    var competitionId: Int {
        return Int(_competition.components(separatedBy: "/").last ?? "-1") ?? -1
    }
    
    var entryId: Int {
        return Int(
            _entry.components(separatedBy: "/").last ?? "-1"
        ) ?? -1
    }
    
    var userId: Int {
        return Int(
            _user.components(separatedBy: "/").last ?? "-1"
        ) ?? -1
    }
    
    var createDate: Date {
        return _createDate
    }
}
