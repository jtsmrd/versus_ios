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
    
    private init() { }
    
    
    func createCompetitionEntry(
        categoryType: CategoryType,
        competitionType: CompetitionType,
        caption: String?,
        videoPreviewImageId: String?,
        videoPreviewImageSmallId: String?,
        videoId: String?,
        imageId: String?,
        imageSmallId: String?,
        completion: @escaping SuccessCompletion) {
        
        let competitionEntry: AWSCompetitionEntry = AWSCompetitionEntry()
        competitionEntry._id = UUID().uuidString
        competitionEntry._caption = caption
        competitionEntry._categoryId = categoryType.rawValue.toNSNumber
        competitionEntry._competitionTypeId = competitionType.rawValue.toNSNumber
        competitionEntry._createDate = Date().toISO8601String
        competitionEntry._imageId = imageId ?? "0"
        competitionEntry._imageSmallId = imageSmallId ?? "0"
        competitionEntry._isFeatured = CurrentUser.user.awsUser._isFeatured
        competitionEntry._userPoolUserId = CurrentUser.userPoolUserId
        competitionEntry._userRankId = CurrentUser.user.awsUser._rankId
        competitionEntry._username = CurrentUser.user.awsUser._username
        competitionEntry._videoId = videoId ?? "0"
        competitionEntry._videoPreviewImageId = videoPreviewImageId ?? "0"
        competitionEntry._videoPreviewImageSmallId = videoPreviewImageSmallId ?? "0"
        
        AWSDynamoDBObjectMapper.default().save(competitionEntry) { (error) in
            if let error = error {
                debugPrint("Error when creating competition entry: \(error.localizedDescription)")
                completion(false)
            }
            debugPrint("Competition entry successfully created.")
            completion(true)
        }
    }
    
    
    func uploadCompetitionImage(
        image: UIImage,
        bucketType: S3BucketType,
        competitionImageSizeType: CompetitionImageSizeType,
        completion: @escaping (_ imageFilename: String?) -> Void
    ) {
        guard let uploadImage = resizeImage(image: image, newWidth: competitionImageSizeType.rawValue) else {
            completion(nil)
            return
        }
        S3BucketService.instance.uploadImage(
            image: uploadImage,
            bucketType: bucketType
        ) { (imageFilename) in
            completion(imageFilename)
        }
    }
    
    func uploadCompetitionVideo(
        videoUrlAsset: AVURLAsset,
        bucketType: S3BucketType,
        completion: @escaping (_ videoFilename: String?) -> Void
    ) {
        S3BucketService.instance.uploadVideo(
            videoUrlAsset: videoUrlAsset,
            bucketType: bucketType
        ) { (videoFilename) in
            completion(videoFilename)
        }
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
