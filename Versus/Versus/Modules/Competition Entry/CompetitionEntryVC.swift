//
//  CompetitionEntryVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/19/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import Photos
import AVKit

class CompetitionEntryVC: UIViewController {

    
    @IBOutlet weak var recordContainerView: UIView!
    @IBOutlet weak var uploadContainerView: UIView!
    @IBOutlet weak var avPlayerContainerView: UIView!
    @IBOutlet weak var competitionPictureImageView: UIImageView!
    @IBOutlet weak var photoLibraryCollectionView: UICollectionView!
    @IBOutlet weak var recordUploadSegmentedControl: UISegmentedControl!
    
    
    var mediaAssets = [PHAsset]()
    var selectedImage: UIImage?
    var selectedAVAsset: AVAsset?
    var avPlayerVC: AVPlayerViewController!
    var avPlayer: AVPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureAVPlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getMedia()
    }
    
    // Unwind segue
    @IBAction func unwindFromCompetitionSubmit(segue: UIStoryboardSegue) {
        dismiss(animated: false, completion: nil)
    }

    @IBAction func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonAction() {
        performSegue(withIdentifier: SHOW_COMPETITION_DETAILS, sender: nil)
    }
    
    @IBAction func recordUploadSegmentedControlAction() {
        if recordUploadSegmentedControl.selectedSegmentIndex == 0 {
            recordContainerView.isHidden = false
            uploadContainerView.isHidden = true
        }
        else {
            recordContainerView.isHidden = true
            uploadContainerView.isHidden = false
        }
    }
    
    @IBAction func photoLibraryButtonAction() {
        
    }
    
    
    private func getMedia() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 25
        
        var albumCollections = [PHAssetCollection]()
        
        PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .any,
            options: fetchOptions
        ).enumerateObjects { (collection, count, unsafePointer) in
            albumCollections.append(collection)
        }
        
        // 209 is All Photos album
        if let allPhotosCollection = albumCollections.first(where: { $0.assetCollectionSubtype.rawValue == 209 }) {
            PHAsset.fetchAssets(
                in: allPhotosCollection,
                options: nil
            ).enumerateObjects { (asset, count, unsafePointer) in
                self.mediaAssets.append(asset)
            }
            mediaAssets.reverse()
            DispatchQueue.main.async {
                self.photoLibraryCollectionView.reloadData()
            }
        }
    }
    
    private func configureAVPlayer() {
        avPlayer = AVPlayer()
        avPlayerVC = AVPlayerViewController()
        avPlayerVC.player = avPlayer
        avPlayerVC.view.frame = avPlayerContainerView.frame
        addChildViewController(avPlayerVC)
        avPlayerContainerView.addSubview(avPlayerVC.view)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CompetitionEntryVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PHOTO_LIBRARY_CELL, for: indexPath) as? PhotoLibraryCell {
            cell.configureCell(asset: mediaAssets[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
}

extension CompetitionEntryVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = mediaAssets[indexPath.row]
        
        if asset.mediaType == .video {
            PHImageManager.default().requestAVAsset(
                forVideo: asset,
                options: nil
            ) { (videoAsset, audioMix, info) in
                if let videoAsset = videoAsset {
                    self.selectedImage = nil
                    self.selectedAVAsset = videoAsset
                    self.avPlayer.replaceCurrentItem(with: AVPlayerItem(asset: videoAsset))
                    DispatchQueue.main.async {
                        self.avPlayerContainerView.isHidden = false
                    }
                }
            }
        }
        else if asset.mediaType == .image {
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: competitionPictureImageView.frame.width, height: competitionPictureImageView.frame.height),
                contentMode: .aspectFit,
                options: nil
            ) { (image, infoDict) in
                self.selectedImage = image
                self.selectedAVAsset = nil
                DispatchQueue.main.async {
                    self.competitionPictureImageView.image = image
                    self.avPlayerContainerView.isHidden = true
                }
            }
        }
    }
}
