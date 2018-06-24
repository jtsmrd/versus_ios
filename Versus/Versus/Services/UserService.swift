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
        
        let user: AWSUser = AWSUser()
        user._userPoolUserId = userPoolUserId
        user._username = username
        user._createDate = Date().toISO8601String
        user._isFeatured = 0.toNSNumber
        user._rankId = 1.toNSNumber
        user._wins = 0.toNSNumber
        user._votes = 0.toNSNumber
        
        AWSDynamoDBObjectMapper.default().save(user) { (error) in
            if let error = error {
                debugPrint("Error when saving User: \(error.localizedDescription)")
                completion(false)
            }
            debugPrint("User was successfully created.")
            CurrentUser.user = User(awsUser: user)
            completion(true)
        }
    }
    
    
    func saveUserSNSEndpointARN(
        _ endpointArn: String,
        _ userPoolUserId: String,
        completion: @escaping SuccessErrorCompletion) {
        
        let userSnsEndpointArn: AWSUserSNSEndpointARN = AWSUserSNSEndpointARN()
        userSnsEndpointArn._userPoolUserId = userPoolUserId
        userSnsEndpointArn._endpointArn = endpointArn
        
        AWSDynamoDBObjectMapper.default().save(userSnsEndpointArn) { (error) in
            if let error = error {
                completion(false, CustomError(error: error, title: "", desc: "Failed to save user SNS Endpoint ARN: \(error.localizedDescription)"))
            }
            completion(true, nil)
        }
    }
    
    
    func loadUserSNSEndpointARN(
        _ awsUser: AWSUser,
        completion: @escaping (_ endpointArnRecord: AWSUserSNSEndpointARN?, _ customError: CustomError?) -> Void) {
        
        AWSDynamoDBObjectMapper.default().load(
            AWSUserSNSEndpointARN.self,
            hashKey: awsUser._userPoolUserId!,
            rangeKey: nil
        ) { (record, error) in
            if let error = error {
                completion(nil, CustomError(error: error, title: "", desc: "Could not load User SNS Endpoint ARN"))
            }
            else if let record = record as? AWSUserSNSEndpointARN {
                completion(record, nil)
            }
            else {
                debugPrint("Error: Something else went wrong in loadUserSNSEndpointARN")
                completion(nil, nil)
            }
        }
    }
    
    
    /*
     Loads an AWSUser with the given username.
    */
    func loadUserWithUsername(
        _ username: String,
        completion: @escaping (_ user: User?, _ customError: CustomError?) -> Void) {
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#username = :username"
        queryExpression.expressionAttributeNames = [
            "#username": "username"
        ]
        queryExpression.expressionAttributeValues = [
            ":username": username
        ]
        queryExpression.indexName = "usernameIndex"
        
        AWSDynamoDBObjectMapper.default().query(
            AWSUser.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error loading user: \(error.localizedDescription)")
                completion(nil, CustomError(error: error, title: "", desc: "Unable to load user"))
            }
            else if let result = paginatedOutput {
                if let awsUser = result.items.first as? AWSUser {
                    completion(User(awsUser: awsUser), nil)
                }
                else {
                    completion(nil, nil)
                }
            }
        }
    }
    
    
    /*
     Loads an AWSUser with the given userPoolUserId.
     */
    func loadUserWithUserPoolUserId(
        _ userPoolUserId: String,
        completion: @escaping (_ user: User?, _ customError: CustomError?) -> Void) {
        
        AWSDynamoDBObjectMapper.default().load(
            AWSUser.self,
            hashKey: userPoolUserId,
            rangeKey: nil
        ) { (awsUser, error) in
            if let error = error {
                completion(nil, CustomError(error: error, title: "", desc: "Unable to load user."))
            }
            else if let awsUser = awsUser as? AWSUser {
                completion(User(awsUser: awsUser), nil)
            }
            else {
                debugPrint("Something else went wrong with loadUser with userPoolUserId")
                completion(nil, nil)
            }
        }
    }
    
    
    func loadUserFromFollower(
        _ follower: Follower,
        completion: @escaping (_ user: User?, _ error: CustomError?) -> ()) {
        
        var userPoolUserId = ""
        switch follower.followerType! {
        case .follower:
            userPoolUserId = follower.awsFollower._followerUserId!
        case .following:
            userPoolUserId = follower.awsFollower._followedUserId!
        }
        
        loadUserWithUserPoolUserId(userPoolUserId) { (user, customError) in
            if let customError = customError {
                completion(nil, customError)
            }
            else if let user = user {
                completion(user, nil)
            }
        }
    }
    
    
    func downloadImage(userPoolUserId: String, bucketType: S3BucketType, completion: @escaping (_ image: UIImage?) -> Void) {
        
        S3BucketService.instance.downloadImage(imageName: userPoolUserId, bucketType: bucketType) { (image, error) in
            if let error = error {
                debugPrint("Error downloading profile image in edit profile: \(error.localizedDescription)")
                completion(nil)
            }
            else if let image = image {
                completion(image)
            }
            else {
                completion(nil)
            }
        }
    }
    
    
    func uploadImage(
        image: UIImage,
        bucketType: S3BucketType,
        completion: @escaping (_ imageFilename: String?) -> Void) {
        
        var uploadImage: UIImage!
        
        switch bucketType {
        case .profileImage:
            if let image = resizeProfileImage(image: image) {
                uploadImage = image
            }
            else {
                completion(nil)
            }
        case .profileImageSmall:
            if let image = resizeProfileImageSmall(image: image) {
                uploadImage = image
            }
            else {
                completion(nil)
            }
        case .profileBackgroundImage:
            if let image = resizeProfileBackgroundImage(image: image) {
                uploadImage = image
            }
            else {
                completion(nil)
            }
        case .competitionImage, .competitionImageSmall, .competitionVideo, .competitionVideoPreviewImage, .competitionVideoPreviewImageSmall:
            completion(nil)
        }
        
        S3BucketService.instance.uploadImage(
            image: uploadImage,
            bucketType: bucketType
        ) { (imageFilename) in
            completion(imageFilename)
        }
    }
    
    private func resizeProfileImage(image: UIImage) -> UIImage? {
        let newWidth: CGFloat = 300
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private func resizeProfileImageSmall(image: UIImage) -> UIImage? {
        let newWidth: CGFloat = 150
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private func resizeProfileBackgroundImage(image: UIImage) -> UIImage? {
        let newWidth: CGFloat = 600
        
        let scale: CGFloat = 6/25
        let newHeight = image.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func updateUser(user: AWSUser, completion: @escaping SuccessCompletion) {
        
        user._updateDate = Date().toISO8601String
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
    
    func queryUsers(queryString: String, completion: @escaping ([User], _ custoError: CustomError?) -> Void) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "begins_with(#username, :username) OR begins_with(#displayName, :displayName)"
        scanExpression.expressionAttributeNames = [
            "#username": "username",
            "#displayName": "displayName"
        ]
        
        scanExpression.expressionAttributeValues = [
            ":username": queryString.lowercased(),
            ":displayName": queryString
        ]
        
        var users = [User]()
        
        AWSDynamoDBObjectMapper.default().scan(AWSUser.self, expression: scanExpression) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error loading user: \(error.localizedDescription)")
                completion(users, CustomError(error: error, title: "", desc: "Unable to load users"))
            }
            else if let result = paginatedOutput {
                if let awsUsers = result.items as? [AWSUser] {
                    for awsUser in awsUsers {
                        users.append(User(awsUser: awsUser))
                    }
                }
                completion(users, nil)
            }
        }
    }
    
    func querySuggestedFollowUsers(completion: @escaping ([User], _ customError: CustomError?) -> Void) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "#isFeatured = :isFeatured"
        scanExpression.expressionAttributeNames = [
            "#isFeatured": "isFeatured"
        ]
        
        scanExpression.expressionAttributeValues = [
            ":isFeatured": 1
        ]
        
        var users = [User]()
        
        AWSDynamoDBObjectMapper.default().scan(AWSUser.self, expression: scanExpression) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error loading user: \(error.localizedDescription)")
                completion(users, CustomError(error: error, title: "", desc: "Unable to load suggested users"))
            }
            else if let result = paginatedOutput {
                if let awsUsers = result.items as? [AWSUser] {
                    for awsUser in awsUsers {
                        users.append(User(awsUser: awsUser))
                    }
                }
                completion(users, nil)
            }
        }
    }
}
