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
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        
        cameraButton.delegate = self
        cameraDelegate = self
        
        configureView()
        
        configureAVPlayer()
        
        configureGestureRecognizers()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // When a video was selected and the user navigates back
        // resume video playback.
        if let _ = selectedMedia as? AVURLAsset {
            player.play()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // When a video is selected and the user navigates away
        // pause the video playback.
        if let _ = selectedMedia as? AVURLAsset {
            player.pause()
        }
    }
    
    
    /// Cancel the current media selection or dismiss selecting competition media.
    @IBAction func dismissButtonAction() {
        
        if selectedMedia != nil {
            
            // Remove the existing selected media.
            if player.currentItem != nil {
                player.pause()
                player.replaceCurrentItem(with: nil)
            }
            
            selectedMedia = nil
            
            // Configure the view to the original state.
            configureView()
        }
        else {
            
            cleanUpResources()
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction func flipCameraButtonAction() {
        switchCamera()
    }
    
    
    @IBAction func selectMediaButtonAction() {
        displayImagePicker()
    }
    
    
    @IBAction func continueButtonAction() {
        
        guard let media = selectedMedia else {
            
            // Should never happen since the continue button is hidden
            // when no media is selected.
            displayMessage(message: "Please select an image or video")
            return
        }
        
        // Proceed to next view controller based on media type.
        switch media {
        case is UIImage:
            
            let vc = CompetitionDetailsVC(media: media)
            navigationController?.pushViewController(
                vc,
                animated: true
            )
            
        case is AVURLAsset:
            
            let vc = SelectPreviewImageVC(
                videoAVUrlAsset: media as! AVURLAsset
            )
            navigationController?.pushViewController(
                vc,
                animated: true
            )
            
        default:
            displayMessage(
                message: "Unsupported media type, please select an image or video."
            )
            break
        }
    }
    
    
    @objc func videoViewSingleTapAction(_ sender: UITapGestureRecognizer) {
        
        // Pause or play the video if exists.
        if player.rate == 0 {
            player.play()
        }
        else {
            player.pause()
        }
    }
    
    
    @objc func videoViewDoubleTapAction(_ sender: UITapGestureRecognizer) {
        
        // Restart the video from the beginning if exists.
        player.seek(to: CMTime.zero)
        player.play()
    }
    
    
    /// Configure the view based on the value of media.
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
        case let image as UIImage:
            
            competitionImageView.image = image
            competitionImageContainerView.isHidden = false
            
            competitionVideoContainerView.isHidden = true
            
        case let videoAsset as AVURLAsset:
            
            let playerItem = AVPlayerItem(asset: videoAsset)
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
        
        // Hide capture controls and show the continue button.
        flipCameraButton.isHidden = true
        cameraButton.isHidden = true
        selectMediaButton.isHidden = true
        continueButton.isHidden = false
    }
    
    
    /// Configure the AVPlayer for video media type.
    private func configureAVPlayer() {
        player = AVPlayer()
        videoPlayerLayer = AVPlayerLayer()
        videoPlayerLayer.player = player
        videoPlayerLayer.frame = CGRect(origin: .zero, size: view.frame.size)
        videoPlayerLayer.videoGravity = .resizeAspect
        
        competitionVideoContainerView.layer.addSublayer(videoPlayerLayer)
        
        // When the video reaches the end, restart the playback at the beginning.
        notificationCenter.addObserver(
            forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: nil
        ) { (notification) in
            
            self.player.seek(to: CMTime.zero)
            self.player.play()
        }
    }
    
    
    /// Add gesture recognizers for pausing, playing, and restarting video playback.
    private func configureGestureRecognizers() {
        
        // Pause or play.
        videoViewSingleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(SelectCompetitionMediaVC.videoViewSingleTapAction(_:))
        )
        videoViewSingleTap.numberOfTapsRequired = 1
        competitionVideoContainerView.addGestureRecognizer(videoViewSingleTap)
        
        // Restart from beginning.
        videoViewDoubleTap = UITapGestureRecognizer(
            target: self,
            action: #selector(SelectCompetitionMediaVC.videoViewDoubleTapAction(_:))
        )
        videoViewDoubleTap.numberOfTapsRequired = 2
        competitionVideoContainerView.addGestureRecognizer(videoViewDoubleTap)
    }
    
    
    /// Present the photo library for the user to select an image or video.
    private func displayImagePicker() {
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    /// Remove notificationCenter observer, pause and clear AVPlayer item, and
    /// remove gesture recognizers.
    private func cleanUpResources() {
        
        notificationCenter.removeObserver(player)
        
        if player.currentItem != nil {
            player.pause()
            player.replaceCurrentItem(with: nil)
        }
        
        competitionVideoContainerView.removeGestureRecognizer(videoViewSingleTap)
        competitionVideoContainerView.removeGestureRecognizer(videoViewDoubleTap)
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
    
    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {
        swiftyCam.view.setNeedsLayout()
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
