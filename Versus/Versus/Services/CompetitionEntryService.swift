//
//  CompetitionEntryService.swift
//  Versus
//
//  Created by JT Smrdel on 4/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AWSDynamoDB
import AVKit

enum CompetitionImageSizeType: CGFloat {
    case normal = 600
    case small = 300
}

class CompetitionEntryService {
    
    static let instance = CompetitionEntryService()
    private let dynamoDB = AWSDynamoDBObjectMapper.default()
    private let s3BucketService = S3BucketService.instance
    
    
    private init() { }
    
    
    /// Uploads the competition image and creates a competition entry.
    ///
    /// - Parameters:
    ///   - categoryType: The competition category.
    ///   - caption: (Optional) The caption for the competition.
    ///   - image: The competition image.
    ///   - completion: Returns nil if successful or a CustomError if failed.
    func submitImageCompetitionEntry(
        categoryType: CategoryType,
        caption: String?,
        image: UIImage,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        
        let mediaId = UUID().uuidString
        var uploadError: CustomError?
        let uploadDG = DispatchGroup()
        
        // Perform requests on a background thread.
        DispatchQueue.global(qos: .userInitiated).async {
            
            uploadDG.enter()
            
            self.uploadImageMedia(
                image: image,
                mediaId: mediaId
            ) { (customError) in
                
                uploadError = customError
                uploadDG.leave()
            }
            uploadDG.wait()
            
            // Only create a competition entry if the image uploaded successfully,
            // else return the error.
            if let uploadError = uploadError {
                completion(uploadError)
                return
            }
            
            self.createCompetitionEntry(
                categoryType: categoryType,
                competitionType: .image,
                caption: caption,
                mediaId: mediaId,
                completion: completion
            )
        }
    }
    
    
    /// Uploads the competition video and creates a competition entry.
    ///
    /// - Parameters:
    ///   - categoryType: The competition category.
    ///   - caption: (Optional) The caption for the competition.
    ///   - image: The competition preview image.
    ///   - video: The competition video.
    ///   - completion: Returns nil if successful or a CustomError if failed.
    func submitVideoCompetitionEntry(
        categoryType: CategoryType,
        caption: String?,
        image: UIImage,
        video: AVURLAsset,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        
        let mediaId = UUID().uuidString
        var uploadError: CustomError?
        let uploadDG = DispatchGroup()
        
        // Perform requests on a background thread.
        DispatchQueue.global(qos: .userInitiated).async {
            
            uploadDG.enter()
            
            self.uploadVideoMedia(
                image: image,
                video: video,
                mediaId: mediaId
            ) { (customError) in
                
                uploadError = customError
                uploadDG.leave()
            }
            uploadDG.wait()
            
            // Only create a competition entry if the video uploaded successfully,
            // else return the error.
            if let uploadError = uploadError {
                completion(uploadError)
                return
            }
            
            self.createCompetitionEntry(
                categoryType: categoryType,
                competitionType: .video,
                caption: caption,
                mediaId: mediaId,
                completion: completion
            )
        }
    }
    
    
    /// Creates a new competition entry.
    ///
    /// - Parameters:
    ///   - categoryType: The competition category.
    ///   - competitionType: The type of competition: image or video.
    ///   - caption: (Optional) The caption for the competition.
    ///   - mediaId: The identifier for the competition media.
    ///   - completion: Returns nil if successful or a CustomError if failed.
    private func createCompetitionEntry(
        categoryType: CategoryType,
        competitionType: CompetitionType,
        caption: String?,
        mediaId: String,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        
        let awsCompetitionEntry: AWSCompetitionEntry = AWSCompetitionEntry()
        awsCompetitionEntry._awaitingMatch = 1.toNSNumber
        awsCompetitionEntry._caption = caption
        awsCompetitionEntry._categoryTypeId = categoryType.rawValue.toNSNumber
        awsCompetitionEntry._competitionEntryId = UUID().uuidString
        awsCompetitionEntry._compTypeIdCatTypeIdRankIdMatched = String(
            format: "%d|%d|%d|%d",
            competitionType.rawValue,
            categoryType.rawValue,
            CurrentUser.rankId,
            0
        )
        awsCompetitionEntry._competitionTypeId = competitionType.rawValue.toNSNumber
        awsCompetitionEntry._createDate = Date().toISO8601String
        awsCompetitionEntry._displayName = CurrentUser.displayName
        awsCompetitionEntry._isFeatured = NSNumber(booleanLiteral: CurrentUser.isFeatured)
        awsCompetitionEntry._mediaId = mediaId
        awsCompetitionEntry._rankId = CurrentUser.rankId.toNSNumber
        awsCompetitionEntry._userId = CurrentUser.userId
        awsCompetitionEntry._username = CurrentUser.username
        
        dynamoDB.save(
            awsCompetitionEntry
        ) { (error) in
            
            if let error = error {
                
                completion(CustomError(error: error, message: "Unable to submit competition"))
                return
            }
            
            completion(nil)
        }
    }
    
    
    private func uploadImageMedia(
        image: UIImage,
        mediaId: String,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        var uploadError: CustomError?
        let uploadDG = DispatchGroup()
        
        uploadDG.enter()
        s3BucketService.uploadImage(
            image: image,
            imageType: .regular,
            mediaId: mediaId
        ) { (customError) in
            uploadError = customError
            uploadDG.leave()
        }
        
        uploadDG.enter()
        s3BucketService.uploadImage(
            image: image,
            imageType: .small,
            mediaId: mediaId
        ) { (customError) in
            uploadError = customError
            uploadDG.leave()
        }
        
        uploadDG.notify(queue: .global(qos: .userInitiated)) {
            completion(uploadError)
        }
    }
    
    
    private func uploadVideoMedia(
        image: UIImage,
        video: AVURLAsset,
        mediaId: String,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
        var uploadError: CustomError?
        let uploadDG = DispatchGroup()
        
        uploadDG.enter()
        s3BucketService.uploadVideo(
            video: video,
            mediaId: mediaId
        ) { (customError) in
            uploadError = customError
            uploadDG.leave()
        }
        
        uploadDG.enter()
        s3BucketService.uploadImage(
            image: image,
            imageType: .regular,
            mediaId: mediaId
        ) { (customError) in
            uploadError = customError
            uploadDG.leave()
        }
        
        uploadDG.enter()
        s3BucketService.uploadImage(
            image: image,
            imageType: .small,
            mediaId: mediaId
        ) { (customError) in
            uploadError = customError
            uploadDG.leave()
        }
        
        uploadDG.notify(queue: .global(qos: .userInitiated)) {
            completion(uploadError)
        }
    }
}
