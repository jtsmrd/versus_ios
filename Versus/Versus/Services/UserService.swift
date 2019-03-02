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
    private let dynamoDB = AWSDynamoDBObjectMapper.default()
    private let s3BucketService = S3BucketService.instance
    
    private init() { }
    
    
    /**
     Checks whether or not the given username is taken or not.
     */
    func checkAvailabilityOfUsername(
        username: String,
        completion: @escaping (_ isAvailable: Bool, _ customError: CustomError?) -> Void
    ) {
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#searchUsername = :username"
        queryExpression.expressionAttributeNames = [
            "#searchUsername": "searchUsername"
        ]
        queryExpression.expressionAttributeValues = [
            ":username": username.lowercased()
        ]
        queryExpression.indexName = "searchUsername-index"
        
        dynamoDB.query(
            AWSUser.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(false, CustomError(error: error, message: "Unable to check username availability"))
                return
            }
            let isAvailable = paginatedOutput?.items.isEmpty ?? true
            completion(isAvailable, nil)
        }
    }
    
    
    /**
     
     */
    func createUser(
        username: String,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        guard let userPoolId = AWSCognitoIdentityUserPool.default().currentUser()?.username else {
            debugPrint("AWS user username nil")
            completion(CustomError(error: nil, message: "Unable to authenticate"))
            return
        }
        
        let awsUser: AWSUser = AWSUser()
        awsUser._userId = userPoolId
        awsUser._username = username
        awsUser._displayName = username
        awsUser._searchUsername = username.lowercased()
        awsUser._searchDisplayName = username.lowercased()
        awsUser._createDate = Date().toISO8601String
        awsUser._rankId = 1.toNSNumber
        awsUser._totalWins = 0.toNSNumber
        awsUser._totalTimesVoted = 0.toNSNumber
        awsUser._followerCount = 0.toNSNumber
        awsUser._followedUserCount = 0.toNSNumber
        awsUser._directMessageConversationIds = ["0": "0"]
        
        dynamoDB.save(awsUser) { (error) in
            if let error = error {
                completion(CustomError(error: error, message: "Unable to create account"))
                return
            }
            CurrentUser.setAWSUser(awsUser: awsUser)
            completion(nil)
        }
    }
    
    
    /**
 
     */
    func saveUserSNSEndpointARN(
        endpointArn: String,
        userId: String,
        completion: @escaping SuccessErrorCompletion
    ) {
        let userSnsEndpointArn: AWSUserSNSEndpointARN = AWSUserSNSEndpointARN()
        userSnsEndpointArn._userId = userId
        userSnsEndpointArn._endpointArn = endpointArn
        userSnsEndpointArn._isEnabled = 1.toNSNumber
        
        dynamoDB.save(
            userSnsEndpointArn
        ) { (error) in
            if let error = error {
                completion(false, CustomError(error: error, message: "Unable to save notifiation token"))
                return
            }
            completion(true, nil)
        }
    }
    
    
    /**
     
     */
    func loadUserSNSEndpointARN(
        userId: String,
        completion: @escaping (_ awsEndpointArnRecord: AWSUserSNSEndpointARN?, _ customError: CustomError?) -> Void
    ) {
        dynamoDB.load(
            AWSUserSNSEndpointARN.self,
            hashKey: userId,
            rangeKey: nil
        ) { (record, error) in
            if let error = error {
                completion(nil, CustomError(error: error, message: "Could not load User SNS Endpoint ARN"))
                return
            }
            completion(record as? AWSUserSNSEndpointARN, nil)
        }
    }
    
    
    /**
        Loads an AWSUser with the given username.
    */
    func loadUserWithUsername(
        _ username: String,
        completion: @escaping (_ user: User?, _ customError: CustomError?) -> Void
    ) {
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#searchUsername = :searchUsername"
        queryExpression.expressionAttributeNames = [
            "#searchUsername": "searchUsername"
        ]
        queryExpression.expressionAttributeValues = [
            ":searchUsername": username.lowercased()
        ]
        queryExpression.indexName = "searchUsername-index"
        
        dynamoDB.query(
            AWSUser.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(nil, CustomError(error: error, message: "Unable to load user"))
                return
            }
            if let result = paginatedOutput,
                let awsUser = result.items.first as? AWSUser  {
                completion(User(awsUser: awsUser), nil)
                return
            }
            completion(nil, nil)
        }
    }
    
    
    /**
     Loads an AWSUser with the given userPoolUserId.
     */
    func getUser(
        userId: String,
        completion: @escaping (_ awsUser: AWSUser?, _ customError: CustomError?) -> Void
    ) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.dynamoDB.load(
                AWSUser.self,
                hashKey: userId,
                rangeKey: nil
            ) { (awsUser, error) in
                if let error = error {
                    completion(nil, CustomError(error: error, message: "Unable to load user."))
                    return
                }
                guard let awsUser = awsUser as? AWSUser else {
                    completion(nil, CustomError(error: error, message: "Unable to load user."))
                    return
                }
                completion(awsUser, nil)
            }
        }
    }
    
    
    /**
     
     */
    func updateProfile(
        awsUser: AWSUser,
        profileImage: UIImage?,
        backgroundImage: UIImage?,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        var uploadError: CustomError?
        let uploadDG = DispatchGroup()
        
        if let profileImage = profileImage {
            
            uploadDG.enter()
            s3BucketService.uploadImage(
                image: profileImage,
                imageType: .small,
                mediaId: CurrentUser.userId
            ) { (customError) in
                uploadError = customError
                uploadDG.leave()
            }
        }
        
        if let backgroundImage = backgroundImage {
            
            uploadDG.enter()
            s3BucketService.uploadImage(
                image: backgroundImage,
                imageType: .background,
                mediaId: CurrentUser.userId
            ) { (customError) in
                uploadError = customError
                uploadDG.leave()
            }
        }
        uploadDG.wait()
        
        if let uploadError = uploadError {
            completion(uploadError)
            return
        }
        
        updateUser(
            user: awsUser,
            completion: completion
        )
    }
       
    
    /**
     
     */
    func updateUser(
        user: AWSUser,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        let updateMapperConfig = AWSDynamoDBObjectMapperConfiguration()
        updateMapperConfig.saveBehavior = .updateSkipNullAttributes
        dynamoDB.save(
            user,
            configuration: updateMapperConfig
        ) { (error) in
            if let error = error {
                completion(CustomError(error: error, message: "Unable to update User"))
                return
            }
            completion(nil)
        }
    }
    
    
    /**
     
     */
    func searchUsers(
        queryString: String,
        startKey: [String: AWSDynamoDBAttributeValue]?,
        fetchLimit: Int,
        completion: @escaping (_ users: [User], _ lastEvaluatedKey: [String: AWSDynamoDBAttributeValue]?, _ custoError: CustomError?) -> Void
    ) {
        let scanExpression = AWSDynamoDBScanExpression()
        
        // Scan for username
        if String(queryString[queryString.startIndex]) == "@" {
            scanExpression.filterExpression = "begins_with(#searchUsername, :searchUsername)"
            scanExpression.expressionAttributeNames = [
                "#searchUsername": "searchUsername"
            ]
            scanExpression.expressionAttributeValues = [
                ":searchUsername": queryString.lowercased()
            ]
        }
        else { // Scan for display name
            scanExpression.filterExpression = "begins_with(#searchDisplayName, :searchDisplayName)"
            scanExpression.expressionAttributeNames = [
                "#searchDisplayName": "searchDisplayName"
            ]
            scanExpression.expressionAttributeValues = [
                ":searchDisplayName": queryString.lowercased()
            ]
        }
        scanExpression.limit = fetchLimit.toNSNumber
        scanExpression.exclusiveStartKey = startKey
        
        var users = [User]()
        var lastEvaluatedKey: [String: AWSDynamoDBAttributeValue]?
        dynamoDB.scan(
            AWSUser.self,
            expression: scanExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(users, nil, CustomError(error: error, message: "Unable to load users"))
                return
            }
            if let awsUsers = paginatedOutput?.items as? [AWSUser] {
                lastEvaluatedKey = paginatedOutput?.lastEvaluatedKey
                for awsUser in awsUsers {
                    users.append(User(awsUser: awsUser))
                }
            }
            completion(users, lastEvaluatedKey, nil)
        }
    }
    
    
    /**
     
     */
    func querySuggestedFollowUsers(
        completion: @escaping ([User], _ customError: CustomError?) -> Void
    ) {
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#isFeatured = :isFeatured"
        queryExpression.expressionAttributeNames = [
            "#isFeatured": "isFeatured"
        ]
        queryExpression.expressionAttributeValues = [
            ":isFeatured": 1
        ]
        queryExpression.indexName = "isFeatured-index"
        
        var users = [User]()
        dynamoDB.query(
            AWSUser.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                completion(users, CustomError(error: error, message: "Unable to load suggested users"))
                return
            }
            if let result = paginatedOutput,
                let awsUsers = result.items as? [AWSUser] {
                for awsUser in awsUsers {
                    users.append(User(awsUser: awsUser))
                }
            }
            completion(users, nil)
        }
    }
}
