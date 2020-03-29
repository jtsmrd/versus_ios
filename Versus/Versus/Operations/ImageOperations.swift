//
//  ImageOperations.swift
//  Versus
//
//  Created by JT Smrdel on 9/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation
import UIKit

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
        return queue
    }()
    
    lazy var asyncDownloadsInProgress: [IndexPath: AsyncOperation] = [:]
    lazy var asyncDownloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Async Download Image Queue"
        queue.qualityOfService = QualityOfService.userInitiated
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
            return user.profileImageId
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
                user.profileImage = image
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


class DownloadUserProfileImageOperation: AsyncOperation {
    
    let user: User
    private let s3BucketService = S3BucketService.instance
    
    init(user: User) {
        self.user = user
    }
    
    override func execute() {
        
        if isCancelled { return }
        
        s3BucketService.downloadImage(
            mediaId: user.profileImageId,
            imageType: .regular
        ) { (image, errorMessage) in
            
            if image != nil {
                self.user.profileImageDownloadState = .downloaded
                self.user.profileImage = image
            }
            else {
                self.user.profileImageDownloadState = .failed
            }
            self.isFinished = true
        }
        
        if isCancelled { return }
    }
}


class DownloadCompetitionImageOperation: AsyncOperation {
    
    private let competition: Competition
    private let s3BucketService = S3BucketService.instance
    
    init(competition: Competition) {
        self.competition = competition
    }
    
    override func execute() {
        
        if isCancelled { return }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        s3BucketService.downloadImage(
            mediaId: competition.leftEntry.mediaId,
            imageType: .regular
        ) { (image, errorMessage) in
            
            if image != nil {
                self.competition.leftEntry.imageDownloadState = .downloaded
                self.competition.leftEntry.image = image
            }
            else {
                self.competition.leftEntry.imageDownloadState = .failed
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        s3BucketService.downloadImage(
            mediaId: competition.rightEntry.mediaId,
            imageType: .regular
        ) { (image, errorMessage) in
            
            if image != nil {
                self.competition.rightEntry.imageDownloadState = .downloaded
                self.competition.rightEntry.image = image
            }
            else {
                self.competition.rightEntry.imageDownloadState = .failed
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            self.isFinished = true
        }
        
        if isCancelled { return }
    }
}


class DownloadEntryImageOperation: AsyncOperation {
    
    private let entry: Entry
    private let s3BucketService = S3BucketService.instance
    
    init(entry: Entry) {
        self.entry = entry
    }
    
    override func execute() {
        
        if isCancelled { return }
        
        s3BucketService.downloadImage(
            mediaId: entry.mediaId,
            imageType: .regular
        ) { (image, errorMessage) in
            
            if image != nil {
                self.entry.imageDownloadState = .downloaded
                self.entry.image = image
            }
            else {
                self.entry.imageDownloadState = .failed
            }
            self.isFinished = true
        }
        
        if isCancelled { return }
    }
}


class DownloadNotificationImageOperation: AsyncOperation {
    
    private let notification: Notification
    private let s3BucketService = S3BucketService.instance
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    override func execute() {
        if isCancelled { return }
        
        guard let mediaId = notification.notificationImageId else {
            return
        }
        
        s3BucketService.downloadImage(
            mediaId: mediaId,
            imageType: .regular
        ) { (image, errorMessage) in
            
            if image != nil {
                self.notification.imageDownloadState = .downloaded
                self.notification.image = image
            }
            else {
                self.notification.imageDownloadState = .failed
            }
            self.isFinished = true
        }
        
        if isCancelled { return }
    }
}
