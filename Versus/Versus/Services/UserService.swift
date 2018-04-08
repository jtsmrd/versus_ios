//
//  UserService.swift
//  Versus
//
//  Created by JT Smrdel on 3/31/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSAuthCore
import AWSDynamoDB
import AWSUserPoolsSignIn

class UserService {
    
    static let instance = UserService()
    
    private init() { }
    
    func createUser(username: String, completion: @escaping SuccessCompletion) {
        guard let userPoolUserId = AWSCognitoIdentityUserPool.default().currentUser()?.username else {
            debugPrint("AWS user username nil")
            return
        }
        
        let user: User = User()
        user._username = username
        user._createDate = String(Date().timeIntervalSince1970)
        user._userPoolUserId = userPoolUserId
        
        AWSDynamoDBObjectMapper.default().save(user) { (error) in
            if let error = error {
                debugPrint("Error when saving User: \(error.localizedDescription)")
                completion(false)
            }
            debugPrint("User was successfully created.")
            completion(true)
        }
    }
    
    func loadUser(completion: @escaping (User?) -> ()) {
        guard let userPoolUserId = AWSCognitoIdentityUserPool.default().currentUser()?.username else {
            debugPrint("AWS user username nil")
            return
        }
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userPoolUserId = :userPoolUserId"
        queryExpression.expressionAttributeNames = [
            "#userPoolUserId": "userPoolUserId"
        ]
        queryExpression.expressionAttributeValues = [
            ":userPoolUserId": userPoolUserId
        ]
        queryExpression.indexName = "userPoolUserIdIndex"

        AWSDynamoDBObjectMapper.default().query(User.self, expression: queryExpression) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error loading user: \(error.localizedDescription)")
                completion(nil)
            }
            else if let result = paginatedOutput {
                if let user = result.items.first as? User {
                    completion(user)
                }
            }
        }
    }
    
    func updateUser(user: User, completion: @escaping SuccessCompletion) {
        
        user._updateDate = String(Date().timeIntervalSince1970)
        let updateMapperConfig = AWSDynamoDBObjectMapperConfiguration()
        updateMapperConfig.saveBehavior = .updateSkipNullAttributes
        AWSDynamoDBObjectMapper.default().save(user, configuration: updateMapperConfig) { (error) in
            if let error = error {
                debugPrint("Error when updating User: \(error.localizedDescription)")
                completion(false)
            }
            debugPrint("User was successfully updated.")
            completion(true)
        }
    }
    
    func getUserEmail() -> String {
        
        return ""
    }
}
