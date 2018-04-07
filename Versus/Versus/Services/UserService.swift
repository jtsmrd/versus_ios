//
//  UserService.swift
//  Versus
//
//  Created by JT Smrdel on 3/31/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSAuthCore
import AWSDynamoDB

class UserService {
    
    static let instance = UserService()
    
    private init() { }
    
    func createUser(userPoolUserId: String, username: String) {
        let user: User = User()
        user._username = username
        user._createDate = String(Date().timeIntervalSince1970)
        user._userPoolUserId = userPoolUserId
        
        AWSDynamoDBObjectMapper.default().save(user) { (error) in
            if let error = error {
                debugPrint("Error when saving User: \(error.localizedDescription)")
                return
            }
            debugPrint("User was successfully created.")
        }
    }
    
    func loadUser() {
        
    }
    
    func updateUser() {
        
    }
}
