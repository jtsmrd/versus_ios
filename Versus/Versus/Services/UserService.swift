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
        user._username = username
        user._createDate = Date().iso8601
        user._userPoolUserId = userPoolUserId
        user._rankId = NSNumber(integerLiteral: 1)
        user._wins = NSNumber(integerLiteral: 0)
        user._votes = NSNumber(integerLiteral: 0)
        
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
    
    func loadUser(
        userPoolUserId: String,
        completion: @escaping (_ awsUser: AWSUser?, _ error: CustomError?) -> ()) {
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#userPoolUserId = :userPoolUserId"
        queryExpression.expressionAttributeNames = [
            "#userPoolUserId": "userPoolUserId"
        ]
        queryExpression.expressionAttributeValues = [
            ":userPoolUserId": userPoolUserId
        ]
        queryExpression.indexName = "userPoolUserIdIndex"

        AWSDynamoDBObjectMapper.default().query(
            AWSUser.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error loading user: \(error.localizedDescription)")
                completion(nil, CustomError(error: error, title: "", desc: "Unable to load user"))
            }
            else if let result = paginatedOutput {
                if let user = result.items.first as? AWSUser {
                    completion(user, nil)
                }
                else {
                    completion(nil, nil)
                }
            }
        }
    }
    
    
    func loadUser(
        fromFollower follower: Follower,
        completion: @escaping (_ awsUser: AWSUser?, _ error: CustomError?) -> ()) {
        
        var userPoolUserId = ""
        switch follower.followerType! {
        case .follower:
            userPoolUserId = follower.awsFollower._followerUserId!
        case .following:
            userPoolUserId = follower.awsFollower._followedUserId!
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
        
        AWSDynamoDBObjectMapper.default().query(
            AWSUser.self,
            expression: queryExpression
        ) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error loading user: \(error.localizedDescription)")
                completion(nil, CustomError(error: error, title: "", desc: "Unable to load user"))
            }
            else if let result = paginatedOutput {
                if let user = result.items.first as? AWSUser {
                    completion(user, nil)
                }
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
        case .competitionImage, .competitionVideo, .competitionVideoPreviewImage:
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
        let newHeight: CGFloat = 600
        
        let scale: CGFloat = 6/25
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func updateUser(user: AWSUser, completion: @escaping SuccessCompletion) {
        
        user._updateDate = Date().iso8601
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
    
    func queryUsers(queryString: String, completion: @escaping ([AWSUser]?) -> Void) {
        
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
        
        AWSDynamoDBObjectMapper.default().scan(AWSUser.self, expression: scanExpression) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error loading user: \(error.localizedDescription)")
                completion(nil)
            }
            else if let result = paginatedOutput {
                if let users = result.items as? [AWSUser] {
                    completion(users)
                }
                else {
                    completion([AWSUser]())
                }
            }
        }
    }
    
    func querySuggestedFollowUsers(completion: @escaping ([AWSUser]?) -> Void) {
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "#isFeatured = :isFeatured"
        scanExpression.expressionAttributeNames = [
            "#isFeatured": "isFeatured"
        ]
        
        scanExpression.expressionAttributeValues = [
            ":isFeatured": 1
        ]
        
        AWSDynamoDBObjectMapper.default().scan(AWSUser.self, expression: scanExpression) { (paginatedOutput, error) in
            if let error = error {
                debugPrint("Error loading user: \(error.localizedDescription)")
                completion(nil)
            }
            else if let result = paginatedOutput {
                if let users = result.items as? [AWSUser] {
                    completion(users)
                }
                else {
                    completion([AWSUser]())
                }
            }
        }
    }
}
