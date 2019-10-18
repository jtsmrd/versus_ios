//
//  ImageOperations.swift
//  Versus
//
//  Created by JT Smrdel on 9/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

enum ImageDownloadState {
    case new
    case downloaded
    case failed
}


class ImageOperations {
    
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download Image Queue"
        queue.qualityOfService = QualityOfService.userInitiated
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
    
    lazy var asyncDownloadsInProgress: [IndexPath: AsyncOperation] = [:]
    lazy var asyncDownloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Async Download Image Queue"
        queue.qualityOfService = QualityOfService.userInitiated
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
}


class DownloadImageOperation: AsyncOperation {
    
    let entity: AnyObject
    private let s3BucketService = S3BucketService.instance
    
    
    init(entity: AnyObject) {
        self.entity = entity
    }
    
    
    override func execute() {
        
        if isCancelled { return }
        
        s3BucketService.downloadImage(
            mediaId: getMediaId(),
            imageType: .regular
        ) { (image, errorMessage) in
            
            self.setOperationResult(
                image: image,
                errorMessage: errorMessage
            )
        }
        
        if isCancelled { return }
    }
    
    
    private func getMediaId() -> String {
        
        if let user = entity as? User {
            return user.profileImage
        }
        else if let entry = entity as? Entry {
            return entry.mediaId
        }
        
        return ""
    }
    
    
    private func setOperationResult(image: UIImage?, errorMessage: String?) {
        
        if let user = entity as? User {
            
            if image != nil {
                user.profileImageDownloadState = .downloaded
                user.profileImageImage = image
                return
            }
            user.profileImageDownloadState = .failed
        }
        else if let entry = entity as? Entry {
            
            if image != nil {
                entry.imageDownloadState = .downloaded
                entry.image = image
                return
            }
            entry.imageDownloadState = .failed
        }
    }
}


class DownloadUserProfileImageOperation: Operation {
    
    
    let user: User
    private let s3BucketService = S3BucketService.instance
    
    
    init(user: User) {
        self.user = user
    }
    
    
    override func main() {
        
        if isCancelled { return }
        
        s3BucketService.downloadImage(
            mediaId: user.profileImage,
            imageType: .regular
        ) { (image, errorMessage) in
            
            if image != nil {
                self.user.profileImageDownloadState = .downloaded
                self.user.profileImageImage = image
                return
            }
            self.user.profileImageDownloadState = .failed
        }
        
        if isCancelled { return }
    }
}


class DownloadCompetitionImageOperation: Operation {
    
    
    let competition: Competition
    private let s3BucketService = S3BucketService.instance
    
    
    init(competition: Competition) {
        self.competition = competition
    }
    
    
    override func main() {
        
        if isCancelled { return }
        
        s3BucketService.downloadImage(
            mediaId: competition.leftEntry.mediaId,
            imageType: .regular
        ) { (image, errorMessage) in
            
            if image != nil {
                self.competition.leftEntry.imageDownloadState = .downloaded
                self.competition.leftEntry.image = image
                return
            }
            self.competition.leftEntry.imageDownloadState = .failed
        }
        
        s3BucketService.downloadImage(
            mediaId: competition.rightEntry.mediaId,
            imageType: .regular
        ) { (image, errorMessage) in
            
            if image != nil {
                self.competition.rightEntry.imageDownloadState = .downloaded
                self.competition.rightEntry.image = image
                return
            }
            self.competition.rightEntry.imageDownloadState = .failed
        }
        
        if isCancelled { return }
    }
}


class DownloadEntryImageOperation: Operation {
    
    
    let entry: Entry
    private let s3BucketService = S3BucketService.instance
    
    
    init(entry: Entry) {
        self.entry = entry
    }
    
    
    override func main() {
        
        if isCancelled { return }
        
        s3BucketService.downloadImage(
            mediaId: entry.mediaId,
            imageType: .regular
        ) { (image, errorMessage) in
            
            if image != nil {
                self.entry.imageDownloadState = .downloaded
                self.entry.image = image
                return
            }
            self.entry.imageDownloadState = .failed
        }
        
        if isCancelled { return }
    }
}
