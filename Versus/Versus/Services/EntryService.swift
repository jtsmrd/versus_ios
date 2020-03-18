//
//  EntryService.swift
//  Versus
//
//  Created by JT Smrdel on 4/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import AVKit

enum CompetitionImageSizeType: CGFloat {
    case normal = 600
    case small = 300
}

class EntryService {
    
    static let instance = EntryService()
    
    private let networkManager = NetworkManager()
    private let router = Router<EntryEndpoint>()
    private let s3BucketService = S3BucketService.instance
    
    
    private init() { }
    
    
    
    /// Creates a new Entry.
    ///
    /// - Parameters:
    ///   - caption: (optional) Entry caption.
    ///   - categoryId: The category id.
    ///   - typeId: The entry type id.
    ///   - mediaId: The uploaded media id.
    ///   - completion: (optional) error message.
    private func createEntry(
        caption: String,
        categoryId: Int,
        typeId: Int,
        mediaId: String,
        completion: @escaping (_ error: String?) -> ()
    ) {
        
        router.request(
            .create(
                caption: caption,
                categoryId: categoryId,
                typeId: typeId,
                mediaId: mediaId
            )
        ) { (data, response, error) in
            
            if error != nil {
                completion("Please check your network connection.")
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    completion(nil)
                    
                case .failure(let networkFailureError):
                    
                    completion(networkFailureError)
                }
            }
        }
    }
    
    
    
    /// Gets unmatched entries for the given user id.
    ///
    /// - Parameters:
    ///   - id: User.id
    ///   - completion: [Entry] | error message
    func loadEntries(
        userId: Int,
        completion: @escaping (_ entries: [Entry], _ error: String?) -> ()
    ) {
        
        router.request(
            .loadEntries(
                userId: userId
            )
        ) { (data, response, error) in
            
            var entries = [Entry]()
            
            if error != nil {
                completion(
                    entries,
                    "Please check your network connection."
                )
            }
            
            if let response = response as? HTTPURLResponse {
                
                let result = self.networkManager.handleNetworkResponse(response)
                
                switch result {
                    
                case .success:
                    
                    guard let responseData = data else {
                        completion(
                            entries,
                            NetworkResponse.noData.rawValue
                        )
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    do {
                        entries = try decoder.decode([Entry].self, from: responseData)
                        completion(entries, nil)
                    }
                    catch {
                        completion(
                            entries,
                            NetworkResponse.unableToDecode.rawValue
                        )
                    }
                    // apiplatform event listener serializelistener
                case .failure(let networkFailureError):
                    
                    completion(entries, networkFailureError)
                }
            }
        }
    }
    
    
    
    /// Uploads the competition image and creates a competition entry.
    ///
    /// - Parameters:
    ///   - categoryType: The competition category.
    ///   - caption: (Optional) The caption for the competition.
    ///   - image: The competition image.
    ///   - completion: Returns nil if successful or an error message if failed.
    func submitImageEntry(
        image: UIImage,
        caption: String?,
        categoryType: CategoryType,
        completion: @escaping (_ error: String?) -> Void
    ) {
        
        let mediaId = UUID().uuidString
        var uploadError: String?
        let uploadDG = DispatchGroup()

        // Perform requests on a background thread.
        DispatchQueue.global(qos: .userInitiated).async {

            uploadDG.enter()

            self.uploadImageMedia(
                image: image,
                mediaId: mediaId
            ) { (customError) in

                uploadError = customError?.message
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
                caption: caption ?? "",
                categoryId: categoryType.rawValue,
                typeId: CompetitionType.image.rawValue,
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
    ///   - completion: Returns nil if successful or an error message if failed.
    func submitVideoEntry(
        image: UIImage,
        video: AVURLAsset,
        caption: String?,
        categoryType: CategoryType,
        completion: @escaping (_ error: String?) -> Void
    ) {
        
        let mediaId = UUID().uuidString
        var uploadError: String?
        let uploadDG = DispatchGroup()

        // Perform requests on a background thread.
        DispatchQueue.global(qos: .userInitiated).async {

            uploadDG.enter()

            self.uploadVideoMedia(
                image: image,
                video: video,
                mediaId: mediaId
            ) { (customError) in

                uploadError = customError?.message
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
                caption: caption ?? "",
                categoryId: categoryType.rawValue,
                typeId: CompetitionType.video.rawValue,
                mediaId: mediaId,
                completion: completion
            )
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
