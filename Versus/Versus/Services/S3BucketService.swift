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
    case image
    case video
}

enum ImageType: String {
    case regular = ""
    case small = "_S"
    case background = "_BG"
}

class S3BucketService {
    
    static let instance = S3BucketService()
    private let transferUtility = AWSS3TransferUtility.default()
    
    private init() { }
    
    
    //TODO: resize image based on bucket type
    func uploadImage(
        image: UIImage,
        imageType: ImageType,
        mediaId: String,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        guard let compressedImage = image.compressImage(imageType: imageType),
            let imageData = compressedImage.jpegData(compressionQuality: 1.0) else {
            completion(CustomError(error: nil, message: "Unable to upload image"))
            return
        }
        
        let mediaKey = generateImageMediaKey(mediaId: mediaId, imageType: imageType)
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async {
                // Display progress UI
            }
        }
        
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = {
            (task, error) -> Void in
                if let error = error {
                    completion(CustomError(error: error, message: "Error uploading image"))
                    return
                }
                completion(nil)
        }
        
        transferUtility.uploadData(
            imageData,
            bucket: S3_BUCKET,
            key: mediaKey,
            contentType: "image/jpeg",
            expression: expression,
            completionHandler: completionHandler
        ).continueWith { (task) -> Any? in
            if let error = task.error {
                debugPrint("Error uploading image: \(error.localizedDescription)")
            }
            else if let _ = task.result {
                
            }
            return nil
        }
    }
    
    func downloadImage(
        mediaId: String,
        imageType: ImageType,
        completion: @escaping (_ image: UIImage?, _ customError: CustomError?) -> Void
    ) {
        let mediaKey = generateImageMediaKey(mediaId: mediaId, imageType: imageType)
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async {
                // Display progress UI
            }
        }
        
        let completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = {
            (task, url, data, error) -> Void in
                if let error = error {
                    completion(nil, CustomError(error: error, message: "Unable to download image"))
                    return
                }
                if let imageData = data {
                    completion(UIImage(data: imageData), nil)
                    return
                }
                completion(nil, CustomError(error: nil, message: "Unable to download image - non-error"))
            
        }
        
        transferUtility.downloadData(
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
        video: AVURLAsset,
        mediaId: String,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        
        guard let videoData = try? Data(contentsOf: video.url) else {
            completion(CustomError(error: nil, message: "Unable to upload video"))
            return
        }
        
        let mediaKey = generateVideoMediaKey(mediaId: mediaId)
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async {
                // Display progress UI
            }
        }
        
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = {
            (task, error) -> Void in
                if let error = error {
                    completion(CustomError(error: error, message: "Error uploading video"))
                    return
                }
                completion(nil)
        }
        
        transferUtility.uploadData(
            videoData,
            bucket: S3_BUCKET,
            key: mediaKey,
            contentType: "video/quicktime",
            expression: expression,
            completionHandler: completionHandler
        ).continueWith { (task) -> Any? in
            if let error = task.error {
                debugPrint("Error uploading video: \(error.localizedDescription)")
            }
            else if let _ = task.result {
                
            }
            return nil
        }
    }
    
    
    func downloadVideo(
        mediaId: String,
        bucketType: S3BucketType,
        completion: @escaping (_ videoAsset: AVURLAsset?, _ customError: CustomError?) -> Void
    ) {
        let mediaKey = generateVideoMediaKey(mediaId: mediaId)
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async {
                // Display progress UI
            }
        }
        
        let completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = {
            (task, url, data, error) -> Void in
                if let error = error {
                    completion(nil, CustomError(error: error, message: "Error downloading video"))
                }
                else if let data = data {
                    
                    var videoUrl: URL?
                    do {
                        videoUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(mediaId + ".mov")
                        if let videoUrl = videoUrl {
                            try data.write(to: videoUrl)
                        }
                        else {
                            debugPrint("Video url is nil")
                        }
                    }
                    catch {
                        debugPrint("Could not write video data to file system: \(error.localizedDescription)")
                    }
                    
                    let videoUrlAsset = AVURLAsset(url: videoUrl!)
                    completion(videoUrlAsset, nil)
                }
                else {
                    debugPrint("Failed to receive video data")
                }
        }
        
        transferUtility.downloadData(
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
    
    
    private func generateImageMediaKey(mediaId: String, imageType: ImageType) -> String {
        return String(format: "%@%@%@.jpg", IMAGE_BUCKET, mediaId, imageType.rawValue)
    }
    
    
    private func generateVideoMediaKey(mediaId: String) -> String {
        return String(format: "%@%@.mov", VIDEO_BUCKET, mediaId)
    }
    
    
    private func resizeImage(image: UIImage, imageType: ImageType) -> UIImage? {
        var newWidth: CGFloat = 0
        var scale: CGFloat = 0
        var newHeight: CGFloat = 0
        
        switch imageType {
        case .regular:
            newWidth = 300
            scale = newWidth / image.size.width
            newHeight = image.size.height * scale
            
        case .small:
            newWidth = 150
            scale = newWidth / image.size.width
            newHeight = image.size.height * scale
            
        case .background:
            newWidth = 600
            scale = 6/25
            newHeight = image.size.width * scale
        }
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
