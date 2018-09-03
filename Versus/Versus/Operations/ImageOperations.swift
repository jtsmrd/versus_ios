//
//  ImageOperations.swift
//  Versus
//
//  Created by JT Smrdel on 9/1/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

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
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
