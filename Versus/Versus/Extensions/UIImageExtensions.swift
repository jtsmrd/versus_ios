//
//  UIImageExtensions.swift
//  Versus
//
//  Created by JT Smrdel on 4/8/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

extension UIImage {
    
    // scale images while keeping transparencies
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(self.cgImage!, in: newRect)
            let newImage = UIImage(cgImage: context.makeImage()!)
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
    
    /**
        Reduce file size by a factor of 10
     */
    func compressImage(imageType: ImageType) -> UIImage? {
        var maxHeight: CGFloat = 1136.0
        var maxWidth: CGFloat = 640.0
        
        switch imageType {
        case .background:
            maxWidth = 500.0
            maxHeight = maxWidth * (7.0 / 25.0)  // Background image ratio is 25:7
        case .regular:
            maxWidth = 414.0
            maxHeight = 736.0
        case .small:
            maxWidth = 414.0 / 2.0  // Half of the largest screen width
            maxHeight = maxWidth
        }
        
        var actualHeight: CGFloat = self.size.height
        var actualWidth: CGFloat = self.size.width
        var imgRatio: CGFloat = actualWidth / actualHeight
        let maxRatio: CGFloat = maxWidth / maxHeight
        var compressionQuality: CGFloat = 0.5
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
                compressionQuality = 1
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        guard let imageData = img.jpegData(compressionQuality: compressionQuality) else { return nil }
        return UIImage(data: imageData)
    }
}
