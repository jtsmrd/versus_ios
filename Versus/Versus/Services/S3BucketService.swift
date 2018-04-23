//
//  S3BucketService.swift
//  Versus
//
//  Created by JT Smrdel on 4/7/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation
import AWSCore
import AWSS3
import AWSUserPoolsSignIn

enum S3BucketType {
    case profileImage
    case profileImageSmall
    case profileBackgroundImage
    case competitionImage
    case competitionVideo
    case competitionVideoPreviewImage
}

class S3BucketService {
    
    static let instance = S3BucketService()
    
    private init() { }
    
    func uploadImage(image: UIImage, bucketType: S3BucketType, completion: @escaping (Bool) -> Void) {
        
        guard let imageData = UIImageJPEGRepresentation(image, 1.0) else {
            debugPrint("Could not convert image to jpeg data")
            completion(false)
            return
        }
        
        guard let userPoolUserId = AWSCognitoIdentityUserPool.default().currentUser()?.username else {
            debugPrint("AWS user username nil")
            completion(false)
            return
        }
        
        let imageKey = generateImageKey(imageName: userPoolUserId, bucketType: bucketType)
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async {
                // Display progress UI
            }
        }
        
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock!
        completionHandler = {(task, error) -> Void in
            debugPrint("Successfully uploaded image")
            completion(true)
        }
        
        AWSS3TransferUtility.default().uploadData(
            imageData,
            bucket: S3_BUCKET,
            key: imageKey,
            contentType: "image/jpeg",
            expression: expression,
            completionHandler: completionHandler
        ).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            if let error = task.error {
                debugPrint("Error uploading image: \(error.localizedDescription)")
            }
            else if let _ = task.result {
                
            }
            return nil
        }
    }
    
    func downloadImage(imageName: String, bucketType: S3BucketType, completion: @escaping (UIImage?, Error?) -> Void) {
        
        let imageKey = generateImageKey(imageName: imageName, bucketType: bucketType)
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async {
                // Display progress UI
            }
        }
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock!
        completionHandler = {(task, url, data, error) -> Void in
            if let error = error {
                debugPrint("Failed to download image: \(error.localizedDescription)")
                completion(nil, error)
            }
            else if let imageData = data, let image = UIImage(data: imageData) {
                debugPrint("Successfully downloaded image")
                completion(image, nil)
            }
        }

        AWSS3TransferUtility.default().downloadData(
            fromBucket: S3_BUCKET,
            key: imageKey,
            expression: expression,
            completionHandler: completionHandler
        ).continueWith { (task) -> Any? in
            if let error = task.error {
                debugPrint("Error downloading image: \(error.localizedDescription)")
            }
            else if let _ = task.result {
                
            }
            return nil
        }
    }
    
    
    
    private func generateImageKey(imageName: String, bucketType: S3BucketType) -> String {
        
        switch bucketType {
        case .profileImage:
            return "\(PROFILE_IMAGE_BUCKET_PATH)\(imageName).jpg"
        case .profileImageSmall:
            return "\(PROFILE_IMAGE_SMALL_BUCKET_PATH)\(imageName).jpg"
        case .profileBackgroundImage:
            return "\(PROFILE_BACKGROUND_IMAGE_BUCKET_PATH)\(imageName).jpg"
        case .competitionImage:
            return "\(COMPETITION_IMAGE_BUCKET_PATH)\(imageName).jpg"
        case .competitionVideo:
            return "\(COMPETITION_VIDEO_BUCKET_PATH)\(imageName).jpg"
        case .competitionVideoPreviewImage:
            return "\(COMPETITION_VIDEO_PREVIEW_IMAGE_BUCKET_PATH)\(imageName).jpg"
        }
    }
}
