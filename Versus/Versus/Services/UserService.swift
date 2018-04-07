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
        
//        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
//
//        let noteItem: Notes = Notes()
//
//        noteItem._userId = AWSIdentityManager.default().identityId
//        noteItem._noteId = noteId
//
//        if (!noteTitle.isEmpty){
//            noteItem._title = noteTitle
//        } else {
//            noteItem._title = emptyTitle
//        }
//
//        if (!noteContent.isEmpty){
//            noteItem._content = noteContent
//        } else {
//            noteItem._content = emptyContent
//        }
//
//        noteItem._updatedDate = NSDate().timeIntervalSince1970 as NSNumber
//        let updateMapperConfig = AWSDynamoDBObjectMapperConfiguration()
//        updateMapperConfig.saveBehavior = .updateSkipNullAttributes //ignore any null value attributes and does not remove in database
//        dynamoDbObjectMapper.save(noteItem, configuration: updateMapperConfig, completionHandler: {(error: Error?) -> Void in
//            if let error = error {
//                print(" Amazon DynamoDB Save Error on note update: \(error)")
//                return
//            }
//            print("Existing note updated in DDB.")
//        })
    }
}
