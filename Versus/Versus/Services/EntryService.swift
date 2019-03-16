//
//  EntryService.swift
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

class EntryService {
    
    static let instance = EntryService()
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
    func submitImageEntry(
        image: UIImage,
        caption: String?,
        categoryType: CategoryType,
        displayName: String,
        isFeatured: Bool,
        rank: Rank,
        userId: String,
        username: String,
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
            
            self.createEntry(
                caption: caption,
                categoryTypeId: categoryType.rawValue,
                competitionTypeId: CompetitionType.image.rawValue,
                displayName: displayName,
                isFeatured: isFeatured,
                mediaId: mediaId,
                rankId: rank.id,
                userId: userId,
                username: username,
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
    func submitVideoEntry(
        image: UIImage,
        video: AVURLAsset,
        caption: String?,
        categoryType: CategoryType,
        displayName: String,
        isFeatured: Bool,
        rank: Rank,
        userId: String,
        username: String,
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
            
            self.createEntry(
                caption: caption,
                categoryTypeId: categoryType.rawValue,
                competitionTypeId: CompetitionType.video.rawValue,
                displayName: displayName,
                isFeatured: isFeatured,
                mediaId: mediaId,
                rankId: rank.id,
                userId: userId,
                username: username,
                completion: completion
            )
        }
    }
    
    
    
    /// Returns a collection of unmatched competition entries for the specified user.
    ///
    /// - Parameters:
    ///   - userId: The userId for the unmatched competition entries.
    ///   - completion: A collection of Entry objects and a
    ///     CustomError if request fails.
    func getUnmatchedCompetitionEntries(
        userId: String,
        completion: @escaping ([Entry], CustomError?) -> Void
    ) {
        
        var responseError: CustomError?
        var unmatchedCompetitionEntries = [Entry]()
        
        let endpoint = Endpoints.getUnmatchedCompetitionEntries(userId: userId)
        
        guard let url = URL(string: endpoint) else {

            responseError = CustomError(error: nil, message: "Unable to load competition entries.")
            completion(unmatchedCompetitionEntries, responseError)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                responseError = CustomError(error: error, message: "Failed to load competition entries.")
            }
            
            if let data = data {
                
                let decoder = JSONDecoder()
                
                do {
                    let results = try decoder.decode([Entry].self, from: data)
                    unmatchedCompetitionEntries = results
                }
                catch let decodeError {
                    responseError = CustomError(error: error, message: "Unable to parse competition entries.")
                    debugPrint(decodeError.localizedDescription)
                }
            }
            
            completion(unmatchedCompetitionEntries, responseError)
            
        }.resume()
    }
    
    
    /// Creates a new competition entry.
    ///
    /// - Parameters:
    ///   - categoryType: The competition category.
    ///   - competitionType: The type of competition: image or video.
    ///   - caption: (Optional) The caption for the competition.
    ///   - mediaId: The identifier for the competition media.
    ///   - completion: Returns nil if successful or a CustomError if failed.
    private func createEntry(
        caption: String?,
        categoryTypeId: Int,
        competitionTypeId: Int,
        displayName: String,
        isFeatured: Bool,
        mediaId: String,
        rankId: Int,
        userId: String,
        username: String,
        completion: @escaping (_ customError: CustomError?) -> Void
    ) {
       
        let defaultError = CustomError(error: nil, message: "Unable to create competition entry.")
        
        guard let url = URL(string: Endpoints.INSERT_COMPETITION_ENTRY) else {
            
            completion(defaultError)
            return
        }
        
        let competitionEntry = Entry(
            caption: caption,
            categoryTypeId: categoryTypeId,
            competitionTypeId: competitionTypeId,
            displayName: displayName,
            isFeatured: isFeatured,
            mediaId: mediaId,
            rankId: rankId,
            userId: userId,
            username: username
        )
        
        let encoder = JSONEncoder()
        guard let httpBody = try? encoder.encode(competitionEntry) else {
            
            completion(defaultError)
            return
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                
                let responseError = CustomError(error: error, message: "Failed to create competition entry.")
                completion(responseError)
                return
            }
                
            if let response = response as? HTTPURLResponse {
                
                if response.statusCode == 200 {
                    completion(nil)
                    return
                }
            }
            
            completion(defaultError)
            
        }.resume()
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
