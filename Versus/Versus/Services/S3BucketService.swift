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
}

class S3BucketService {
    
    static let instance = S3BucketService()
    
    private init() { }
    
    func uploadImage(image: UIImage, bucketType: S3BucketType) {
        
        guard let imageData = UIImageJPEGRepresentation(image, 1.0) else {
            debugPrint("Could not convert image to jpeg data")
            return
        }
        
        
        guard let userPoolUserId = AWSCognitoIdentityUserPool.default().currentUser()?.username else {
            debugPrint("AWS user username nil")
            return
        }
        
        var imageKey = ""
        
        switch bucketType {
        case .profileImage:
            imageKey = "\(PROFILE_IMAGE_BUCKET_PATH)\(userPoolUserId).jpg"
        case .profileImageSmall:
            imageKey = "\(PROFILE_IMAGE_SMALL_BUCKET_PATH)\(userPoolUserId).jpg"
        case .profileBackgroundImage:
            imageKey = "\(PROFILE_BACKGROUND_IMAGE_BUCKET_PATH)\(userPoolUserId).jpg"
        }
        
        
        let uploadExpression = AWSS3TransferUtilityUploadExpression()
        uploadExpression.progressBlock = {(task, progress) in
//            DispatchQueue.main.async {
//
//            }
        }
        
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock!
        completionHandler = {(task, error) -> Void in
            debugPrint("Successfully uploaded image")
//            DispatchQueue.main.async {
//
//            }
        }
        
        AWSS3TransferUtility.default().uploadData(
            imageData,
            bucket: S3_BUCKET,
            key: imageKey,
            contentType: "image/jpeg",
            expression: uploadExpression,
            completionHandler: completionHandler)
            .continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
                if let error = task.error {
                    debugPrint("Error uploading image: \(error.localizedDescription)")
                }
                else if let _ = task.result {
                    
                }
                
                return nil
            }
    }
    
    func downloadImage() {
        
    }
}
