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
import MobileCoreServices
import SwiftyCam

class CompetitionEntryVC: UIViewController {

    
    @IBOutlet weak var recordContainerView: UIView!
    @IBOutlet weak var uploadContainerView: UIView!
    @IBOutlet weak var avPlayerContainerView: UIView!
    @IBOutlet weak var competitionPictureImageView: UIImageView!
    @IBOutlet weak var photoLibraryCollectionView: UICollectionView!
    @IBOutlet weak var recordUploadSegmentedControl: UISegmentedControl!
    
    
    var mediaAssets = [PHAsset]()
    var selectedImage: UIImage?
    var selectedVideoAVUrlAsset: AVURLAsset?
    var avPlayerVC: AVPlayerViewController!
    var avPlayer: AVPlayer!
    var imagePicker = UIImagePickerController()
    
    
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
        
        guard inputDataIsValid() else { return }
        
        if let image = selectedImage {
            performSegue(withIdentifier: SHOW_COMPETITION_DETAILS, sender: image)
        }
        else if let videoUrlAsset = selectedVideoAVUrlAsset {
            performSegue(withIdentifier: SHOW_COMPETITION_DETAILS, sender: videoUrlAsset)
        }
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
        displayImagePicker()
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

    private func displayImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func inputDataIsValid() -> Bool {
        
        guard selectedImage != nil || selectedVideoAVUrlAsset != nil else {
            displayMessage(message: "Select image or video")
            return false
        }
        
        return true
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let competitionDetailsVC = segue.destination as? CompetitionDetailsVC {
            if let image = sender as? UIImage {
                competitionDetailsVC.initData(image: image, videoUrlAsset: nil)
            }
            else if let videoUrlAsset = sender as? AVURLAsset {
                competitionDetailsVC.initData(image: nil, videoUrlAsset: videoUrlAsset)
            }
        }
        else if let swiftyCamVC = segue.destination as? SwiftyCamVC {
            swiftyCamVC.videoGravity = .resize
            swiftyCamVC.cameraDelegate = self
        }
    }
}


// MARK: - UIImagePickerControllerDelegate

extension CompetitionEntryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! CFString
        
        switch mediaType {
        case kUTTypeImage:
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                selectedImage = image
                selectedVideoAVUrlAsset = nil
                DispatchQueue.main.async {
                    self.competitionPictureImageView.image = self.selectedImage
                    self.avPlayerContainerView.isHidden = true
                }
            }
        case kUTTypeMovie:
            if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
                selectedVideoAVUrlAsset = AVURLAsset(url: videoUrl)
                selectedImage = nil
                avPlayer.replaceCurrentItem(with: AVPlayerItem(asset: selectedVideoAVUrlAsset!))
                DispatchQueue.main.async {
                    self.avPlayerContainerView.isHidden = false
                }
            }
        default:
            return
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UICollectionViewDataSource

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


// MARK: - UICollectionViewDelegate

extension CompetitionEntryVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = mediaAssets[indexPath.row]
        
        if asset.mediaType == .video {
            PHImageManager.default().requestAVAsset(
                forVideo: asset,
                options: nil
            ) { (videoAsset, audioMix, info) in
                if let videoAsset = videoAsset as? AVURLAsset {
                    self.selectedImage = nil
                    self.selectedVideoAVUrlAsset = videoAsset
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
                self.selectedVideoAVUrlAsset = nil
                DispatchQueue.main.async {
                    self.competitionPictureImageView.image = image
                    self.avPlayerContainerView.isHidden = true
                }
            }
        }
    }
}

extension CompetitionEntryVC: SwiftyCamViewControllerDelegate {
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        debugPrint("Photo taken")
    }
}
