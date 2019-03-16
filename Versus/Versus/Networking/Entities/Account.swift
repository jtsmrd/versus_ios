//
//  Account.swift
//  Versus
//
//  Created by JT Smrdel on 3/10/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

class Account: Codable {
    
    private var _token: String
    private var _user: User
    
    enum CodingKeys: String, CodingKey {
        case _token = "token"
        case _user = "user"
    }
}

extension Account {
    
    
    var token: String {
        return _token
    }
    
    
    var user: User {
        return _user
    }
}
