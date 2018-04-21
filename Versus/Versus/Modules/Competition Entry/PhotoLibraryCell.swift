//
//  PhotoLibraryCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/20/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import Photos

class PhotoLibraryCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configureCell(asset: PHAsset) {
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 55.0, height: 55.0),
            contentMode: .aspectFit,
            options: nil
        ) { (image, infoDict) in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
}
