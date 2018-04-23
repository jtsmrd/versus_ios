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
import AVKit

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
    
    func uploadImage(
        image: UIImage,
        bucketType: S3BucketType,
        completion: @escaping (_ imageFilename: String?) -> Void
    ) {
        
        guard let imageData = UIImageJPEGRepresentation(image, 1.0) else {
            debugPrint("Could not convert image to jpeg data")
            completion(nil)
            return
        }
        
        var imageFilename = CurrentUser.userPoolUserId
        
        if bucketType == .competitionImage || bucketType == .competitionVideoPreviewImage {
            imageFilename = UUID().uuidString
        }
        
        let mediaKey = generateMediaKey(filename: imageFilename, bucketType: bucketType)
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async {
                // Display progress UI
            }
        }
        
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock!
        completionHandler = {(task, error) -> Void in
            if let _ = error {
                completion(nil)
            }
            else {
                debugPrint("Successfully uploaded image")
                completion(imageFilename)
            }
        }
        
        AWSS3TransferUtility.default().uploadData(
            imageData,
            bucket: S3_BUCKET,
            key: mediaKey,
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
    
    func downloadImage(
        imageName: String,
        bucketType: S3BucketType,
        completion: @escaping (UIImage?, Error?) -> Void
    ) {
        
        let mediaKey = generateMediaKey(filename: imageName, bucketType: bucketType)
        
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
            key: mediaKey,
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
    
    func uploadVideo(
        videoUrlAsset: AVURLAsset,
        bucketType: S3BucketType,
        completion: @escaping (_ videoFilename: String?) -> Void
    ) {
        
        guard let videoData = try? Data(contentsOf: videoUrlAsset.url) else {
            completion(nil)
            return
        }
        
        let videoFilename = UUID().uuidString
        
        let mediaKey = generateMediaKey(filename: videoFilename, bucketType: bucketType)
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async {
                // Display progress UI
            }
        }
        
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock!
        completionHandler = {(task, error) -> Void in
            if let _ = error {
                completion(nil)
            }
            else {
                debugPrint("Successfully uploaded video")
                completion(videoFilename)
            }
        }
        
        AWSS3TransferUtility.default().uploadData(
            videoData,
            bucket: S3_BUCKET,
            key: mediaKey,
            contentType: "video/quicktime",
            expression: expression,
            completionHandler: completionHandler
        ).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            if let error = task.error {
                debugPrint("Error uploading video: \(error.localizedDescription)")
            }
            else if let _ = task.result {
                
            }
            return nil
        }
    }
    
    func downloadVideo(
        videoName: String,
        bucketType: S3BucketType,
        completion: @escaping (AVURLAsset?, Error?) -> Void
        ) {
        
        let mediaKey = generateMediaKey(filename: videoName, bucketType: bucketType)
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async {
                // Display progress UI
            }
        }
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock!
        completionHandler = {(task, url, data, error) -> Void in
            if let error = error {
                debugPrint("Failed to download video: \(error.localizedDescription)")
                completion(nil, error)
            }
            else if let videoUrl = url {
                debugPrint("Successfully downloaded video")
                let videoUrlAsset = AVURLAsset(url: videoUrl)
                completion(videoUrlAsset, nil)
            }
        }
        
        AWSS3TransferUtility.default().downloadData(
            fromBucket: S3_BUCKET,
            key: mediaKey,
            expression: expression,
            completionHandler: completionHandler
            ).continueWith { (task) -> Any? in
                if let error = task.error {
                    debugPrint("Error downloading video: \(error.localizedDescription)")
                }
                else if let _ = task.result {
                    
                }
                return nil
        }
    }
    
    private func generateMediaKey(filename: String, bucketType: S3BucketType) -> String {
        
        switch bucketType {
        case .profileImage:
            return "\(PROFILE_IMAGE_BUCKET_PATH)\(filename).jpg"
        case .profileImageSmall:
            return "\(PROFILE_IMAGE_SMALL_BUCKET_PATH)\(filename).jpg"
        case .profileBackgroundImage:
            return "\(PROFILE_BACKGROUND_IMAGE_BUCKET_PATH)\(filename).jpg"
        case .competitionImage:
            return "\(COMPETITION_IMAGE_BUCKET_PATH)\(filename).jpg"
        case .competitionVideo:
            return "\(COMPETITION_VIDEO_BUCKET_PATH)\(filename).mov"
        case .competitionVideoPreviewImage:
            return "\(COMPETITION_VIDEO_PREVIEW_IMAGE_BUCKET_PATH)\(filename).jpg"
        }
    }
}
