//
//  Utilities.swift
//  Versus
//
//  Created by JT Smrdel on 4/22/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AVKit

class Utilities {
    
    
    /// Generate a preview image from the given videoAsset at the specified time.
    ///
    /// - Parameters:
    ///   - videoAsset: The video asset to generate the image from.
    ///   - time: The time in the video to take the image from.
    /// - Returns: Optional UIImage
    static func generateImage(videoAsset: AVURLAsset, time: CMTime) -> UIImage? {
        
        let assetImageGenerator = AVAssetImageGenerator(asset: videoAsset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        assetImageGenerator.requestedTimeToleranceAfter = CMTime.zero
        assetImageGenerator.requestedTimeToleranceBefore = CMTime.zero
        
        do {
            let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        }
        catch {
            return nil
        }
    }
}
