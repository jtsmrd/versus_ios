//
//  SelectCompetitionMediaVC.swift
//  Versus
//
//  Created by JT Smrdel on 12/26/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import SwiftyCam
import Photos
import MobileCoreServices
import AVKit

class SelectCompetitionMediaVC: SwiftyCamViewController {
    
    private let notificationCenter = NotificationCenter.default
    
    @IBOutlet weak var competitionImageContainerView: UIView!
    @IBOutlet weak var competitionImageView: UIImageView!
    @IBOutlet weak var competitionVideoContainerView: UIView!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var cameraButton: SwiftyCamProgressButton!
    @IBOutlet weak var selectMediaButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    
    private var selectedMedia: AnyObject?
    private var imagePicker: UIImagePickerController!
    private var videoPlayerLayer: AVPlayerLayer!
    private var player: AVPlayer!
    private var videoViewSingleTap: UITapGestureRecognizer!
    private var videoViewDoubleTap: UITapGestureRecognizer!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        
        cameraButton.delegate = self
        cameraDelegate = self
        
        configureView()
        
        configureAVPlayer()
        
        configureGestureRecognizers()
    }
    
    
    /**
     Cancel the current media selection or dismiss selecting competition media.
    */
    @IBAction func dismissButtonAction() {
        
        if selectedMedia != nil {
            
            // Remove the existing selected media.
            selectedMedia = nil
            
            // Configure the view to the original state.
            configureView()
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    /**
     Flip the camera to front or back.
    */
    @IBAction func flipCameraButtonAction() {
        switchCamera()
    }
    
    
    /**
     Select a photo or video from the photo library.
    */
    @IBAction func selectMediaButtonAction() {
        displayImagePicker()
    }
    
    
    /**
     Select the current media and proceed to the competition entry details screen.
    */
    @IBAction func continueButtonAction() {
        
        guard let media = selectedMedia else {
            
            // Should never happen since the continue button is hidden
            // when no media is selected.
            displayMessage(message: "Please select an image or video")
            return
        }
        
        switch media {
        case is UIImage:
            
            performSegue(withIdentifier: SHOW_COMPETITION_DETAILS, sender: media)
            
        case is AVURLAsset:
            
            performSegue(withIdentifier: SHOW_SELECT_PREVIEW_IMAGE, sender: media)
            
        default:
            displayMessage(message: "Unsupported media type, please select an image or video.")
            return
        }
    }
    
    
    /**
     Pause or play the video if exists.
    */
    @objc func videoViewSingleTapAction(_ sender: UITapGestureRecognizer) {
        
        if player.rate == 0 {
            player.play()
        }
        else {
            player.pause()
        }
    }
    
    
    /**
     Restart the video from the beginning if exists.
     */
    @objc func videoViewDoubleTapAction(_ sender: UITapGestureRecognizer) {
        player.seek(to: CMTime.zero)
        player.play()
    }
    
    
    /**
     Configure the view for one of three states:
     - No media selected
     - Image selected
     - Video selected
    */
    private func configureView() {
        
        guard let media = selectedMedia else {
            
            // No media is selected.
            // Hide the competitionImageView, videoPlayerLayer, and continueButton.
            // Show the flipCameraButton, cameraButton, and selectMediaButton.
            
            competitionImageContainerView.isHidden = true
            competitionVideoContainerView.isHidden = true
            flipCameraButton.isHidden = false
            cameraButton.isHidden = false
            selectMediaButton.isHidden = false
            continueButton.isHidden = true
            return
        }
        
        // Media is selected
        switch media {
        case is UIImage:
            
            competitionImageView.image = (media as! UIImage)
            competitionImageContainerView.isHidden = false
            
            competitionVideoContainerView.isHidden = true
            
        case is AVURLAsset:
            
            let playerItem = AVPlayerItem(asset: (media as! AVURLAsset))
            player.replaceCurrentItem(with: playerItem)
            player.play()
            competitionVideoContainerView.isHidden = false
            
            competitionImageView.image = nil
            competitionImageContainerView.isHidden = true
            
        default:
            
            displayMessage(message: "Unsupported media type, please select an image or video.")
            selectedMedia = nil
            configureView()
            return
        }
        
        flipCameraButton.isHidden = true
        cameraButton.isHidden = true
        selectMediaButton.isHidden = true
        continueButton.isHidden = false
    }
    
    
    /**
     Configure the AVPlayer for video media type.
     */
    private func configureAVPlayer() {
        player = AVPlayer()
        videoPlayerLayer = AVPlayerLayer()
        videoPlayerLayer.player = player
        videoPlayerLayer.frame = CGRect(origin: .zero, size: view.frame.size)
        videoPlayerLayer.videoGravity = .resizeAspect
        competitionVideoContainerView.layer.addSublayer(videoPlayerLayer)
        
        notificationCenter.addObserver(
            forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: nil
        ) { (notification) in
            self.player.seek(to: CMTime.zero)
            self.player.play()
        }
    }
    
    
    /**
     Add gesture recognizers for pausing, playing, and restarting video playback.
    */
    private func configureGestureRecognizers() {
        
        videoViewSingleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(SelectCompetitionMediaVC.videoViewSingleTapAction(_:))
        )
        videoViewSingleTap.numberOfTapsRequired = 1
        competitionVideoContainerView.addGestureRecognizer(videoViewSingleTap)
        
        videoViewDoubleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(SelectCompetitionMediaVC.videoViewDoubleTapAction(_:))
        )
        videoViewDoubleTap.numberOfTapsRequired = 2
        competitionVideoContainerView.addGestureRecognizer(videoViewDoubleTap)
    }
    
    
    /**
     Present the photo library for the user to select an image or video.
     */
    private func displayImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    /**
     Remove notificationCenter observer, pause and clear AVPlayer item, and
     remove gesture recognizers.
     */
    private func cleanUpResources() {
        
        notificationCenter.removeObserver(player)
        
        if player.currentItem != nil {
            player.pause()
            player.replaceCurrentItem(with: nil)
        }
        
        competitionVideoContainerView.removeGestureRecognizer(videoViewSingleTap)
        competitionVideoContainerView.removeGestureRecognizer(videoViewDoubleTap)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let competitionDetailsVC = segue.destination as? CompetitionDetailsVC, let image = sender as? UIImage {
            competitionDetailsVC.initData(image: image)
        }
        else if let selectPreviewImageVC = segue.destination as? SelectPreviewImageVC, let videoAsset = sender as? AVURLAsset {
            selectPreviewImageVC.initData(videoAVUrlAsset: videoAsset)
        }
    }
}

extension SelectCompetitionMediaVC: SwiftyCamViewControllerDelegate {
    
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        
        // Begin animating the progress indicator.
        cameraButton.beginAnimatingProgress()
    }
    
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        
        // End animating the progress indicator.
        cameraButton.endAnimatingProgress()
    }
    
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        
        // Set the selectedMedia to the image captured.
        selectedMedia = photo
        
        // Configure the view for the image captured.
        configureView()
    }
    
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        
        // Set the selectedMedia to the video recorded.
        selectedMedia = AVURLAsset(url: url)
        
        // Configure the view for the video recorded.
        configureView()
    }
}

extension SelectCompetitionMediaVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        let mediaType = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as! CFString
        
        switch mediaType {
        case kUTTypeImage:
            if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                
                selectedMedia = image
            }
        case kUTTypeMovie:
            if let videoUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL {
                
                selectedMedia = AVURLAsset(url: videoUrl)
            }
        default:
            return
        }
        
        // Configure the view for the image or video selected from the photo library.
        configureView()
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
