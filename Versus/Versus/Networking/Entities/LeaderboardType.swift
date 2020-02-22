//
//  LeaderboardType.swift
//  Versus
//
//  Created by JT Smrdel on 2/21/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import Foundation

class LeaderboardType: Codable {
    
    private var _id: Int
    private var _name: String
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
    }
}

extension LeaderboardType {
    
    var id: Int {
        return _id
    }
    
    var name: String {
        return _name
    }
}
