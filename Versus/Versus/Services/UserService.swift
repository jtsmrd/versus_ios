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
    
    private let networkManager = NetworkManager()
    private let router = Router<UserEndpoint>()
    
    private let dynamoDB = AWSDynamoDBObjectMapper.default()
    private let s3BucketService = S3BucketService.instance
    
    private init() { }
    
    
    
    func loadUser(
        username: String,
        completion: @escaping (_ user: User?, _ errorMessage: String?) -> ()
    ) {
        
        router.request(
            .loadWithUsername(
                username: username
            )
        ) { (data, response, error) in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        let user = try decoder.decode(User.self, from: responseData)
                        completion(user, nil)
                    }
                    catch {
                        debugPrint(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    
    func loadUser(
        userId: Int,
        completion: @escaping (_ user: User?, _ errorMessage: String?) -> ()
    ) {
        
        router.request(
            .load(
                userId: userId
            )
        ) { (data, response, error) in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        let user = try decoder.decode(User.self, from: responseData)
                        completion(user, nil)
                    }
                    catch {
                        debugPrint(error)
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    func updateUser(
        user: User,
        completion: @escaping (_ user: User?, _ errorMessage: String?) -> ()
    ) {
        
        router.request(
            .update(user)
        ) { (data, response, error) in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        let user = try decoder.decode(User.self, from: responseData)
                        completion(user, nil)
                    }
                    catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    func searchByName(
        name: String,
        completion: @escaping (_ users: [User]?, _ errorMessage: String?) -> ()
    ) {
        
        router.request(
            .searchByName(name: name)
        ) { (data, response, error) in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        let users = try decoder.decode([User].self, from: responseData)
                        completion(users, nil)
                    }
                    catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    
    func searchByUsername(
        username: String,
        completion: @escaping (_ users: [User]?, _ errorMessage: String?) -> ()
    ) {
        
        router.request(
            .searchByUsername(username: username)
        ) { (data, response, error) in
            
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        let users = try decoder.decode([User].self, from: responseData)
                        completion(users, nil)
                    }
                    catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                    
                case .failure(let networkFailureError):
                    
                    completion(nil, networkFailureError)
                }
            }
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
//        let queryExpression = AWSDynamoDBQueryExpression()
//        queryExpression.keyConditionExpression = "#searchUsername = :searchUsername"
//        queryExpression.expressionAttributeNames = [
//            "#searchUsername": "searchUsername"
//        ]
//        queryExpression.expressionAttributeValues = [
//            ":searchUsername": username.lowercased()
//        ]
//        queryExpression.indexName = "searchUsername-index"
//
//        dynamoDB.query(
//            AWSUser.self,
//            expression: queryExpression
//        ) { (paginatedOutput, error) in
//            if let error = error {
//                completion(nil, CustomError(error: error, message: "Unable to load user"))
//                return
//            }
//            if let result = paginatedOutput,
//                let awsUser = result.items.first as? AWSUser  {
//                completion(User(awsUser: awsUser), nil)
//                return
//            }
//            completion(nil, nil)
//        }
    }
    
    
    /**
     Loads an AWSUser with the given userPoolUserId.
     */
    func getUser(
        userId: String,
        completion: @escaping (_ awsUser: AWSUser?, _ customError: CustomError?) -> Void
    ) {
        
//        DispatchQueue.global(qos: .userInitiated).async {
//
//            self.dynamoDB.load(
//                AWSUser.self,
//                hashKey: userId,
//                rangeKey: nil
//            ) { (awsUser, error) in
//                if let error = error {
//                    completion(nil, CustomError(error: error, message: "Unable to load user."))
//                    return
//                }
//                guard let awsUser = awsUser as? AWSUser else {
//                    completion(nil, CustomError(error: error, message: "Unable to load user."))
//                    return
//                }
//                completion(awsUser, nil)
//            }
//        }
    }
    
    
    /**
     
     */
    func updateProfile(
        user: User,
        profileImage: UIImage?,
        backgroundImage: UIImage?,
        completion: @escaping (_ user: User?, _ errorMessage: String?) -> ()
    ) {
        var error: String?
        let uploadDG = DispatchGroup()

        let imageId = String(describing: CurrentAccount.user.id)
        
        if let profileImage = profileImage {

            uploadDG.enter()
            s3BucketService.uploadImage(
                image: profileImage,
                imageType: .regular,
                mediaId: imageId
            ) { (customError) in
                
                if customError == nil {
                    user.profileImage = imageId
                }
                
                error = customError?.message
                uploadDG.leave()
            }
        }

        if let backgroundImage = backgroundImage {

            uploadDG.enter()
            s3BucketService.uploadImage(
                image: backgroundImage,
                imageType: .background,
                mediaId: imageId
            ) { (customError) in
                
                if customError == nil {
                    user.backgroundImage = imageId
                }
                
                error = customError?.message
                uploadDG.leave()
            }
        }
        uploadDG.wait()

        if let error = error {
            completion(nil, error)
            return
        }

        updateUser(
            user: user,
            completion: completion
        )
    }
    
    
    /**
     
     */
    func searchUsers(
        queryString: String,
        startKey: [String: AWSDynamoDBAttributeValue]?,
        fetchLimit: Int,
        completion: @escaping (_ users: [User], _ lastEvaluatedKey: [String: AWSDynamoDBAttributeValue]?, _ custoError: CustomError?) -> Void
    ) {
//        let scanExpression = AWSDynamoDBScanExpression()
//
//        // Scan for username
//        if String(queryString[queryString.startIndex]) == "@" {
//            scanExpression.filterExpression = "begins_with(#searchUsername, :searchUsername)"
//            scanExpression.expressionAttributeNames = [
//                "#searchUsername": "searchUsername"
//            ]
//            scanExpression.expressionAttributeValues = [
//                ":searchUsername": queryString.lowercased()
//            ]
//        }
//        else { // Scan for display name
//            scanExpression.filterExpression = "begins_with(#searchDisplayName, :searchDisplayName)"
//            scanExpression.expressionAttributeNames = [
//                "#searchDisplayName": "searchDisplayName"
//            ]
//            scanExpression.expressionAttributeValues = [
//                ":searchDisplayName": queryString.lowercased()
//            ]
//        }
//        scanExpression.limit = fetchLimit.toNSNumber
//        scanExpression.exclusiveStartKey = startKey
//
//        var users = [User]()
//        var lastEvaluatedKey: [String: AWSDynamoDBAttributeValue]?
//        dynamoDB.scan(
//            AWSUser.self,
//            expression: scanExpression
//        ) { (paginatedOutput, error) in
//            if let error = error {
//                completion(users, nil, CustomError(error: error, message: "Unable to load users"))
//                return
//            }
//            if let awsUsers = paginatedOutput?.items as? [AWSUser] {
//                lastEvaluatedKey = paginatedOutput?.lastEvaluatedKey
//                for awsUser in awsUsers {
//                    users.append(User(awsUser: awsUser))
//                }
//            }
//            completion(users, lastEvaluatedKey, nil)
//        }
    }
    
    
    /**
     
     */
    func querySuggestedFollowUsers(
        completion: @escaping ([User], _ customError: CustomError?) -> Void
    ) {
//        let queryExpression = AWSDynamoDBQueryExpression()
//        queryExpression.keyConditionExpression = "#isFeatured = :isFeatured"
//        queryExpression.expressionAttributeNames = [
//            "#isFeatured": "isFeatured"
//        ]
//        queryExpression.expressionAttributeValues = [
//            ":isFeatured": 1
//        ]
//        queryExpression.indexName = "isFeatured-index"
//
//        var users = [User]()
//        dynamoDB.query(
//            AWSUser.self,
//            expression: queryExpression
//        ) { (paginatedOutput, error) in
//            if let error = error {
//                completion(users, CustomError(error: error, message: "Unable to load suggested users"))
//                return
//            }
//            if let result = paginatedOutput,
//                let awsUsers = result.items as? [AWSUser] {
//                for awsUser in awsUsers {
//                    users.append(User(awsUser: awsUser))
//                }
//            }
//            completion(users, nil)
//        }
    }
}
