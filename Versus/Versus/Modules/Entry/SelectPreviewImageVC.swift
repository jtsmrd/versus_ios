//
//  SelectPreviewImageVC.swift
//  Versus
//
//  Created by JT Smrdel on 6/21/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AVKit

class SelectPreviewImageVC: UIViewController {

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var videoSeekSlider: UISlider!
    
    private var videoAVUrlAsset: AVURLAsset!
    private var videoPlayerLayer: AVPlayerLayer!
    private var videoPlayer: AVPlayer!
    private var seekTime: CMTime!
    
    
    
    /// Required initializer.
    ///
    /// - Parameter videoAVUrlAsset: The video asset to generate an image from.
    init(videoAVUrlAsset: AVURLAsset) {
        super.init(nibName: nil, bundle: nil)
        
        self.videoAVUrlAsset = videoAVUrlAsset
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Default the seekTime to 2 seconds.
        seekTime = CMTimeMakeWithSeconds(2, preferredTimescale: 1)
        
        configureAVPlayer()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Resize the player layer to after the views are layed out.
        videoPlayerLayer.frame = CGRect(
            origin: .zero,
            size: videoContainerView.frame.size
        )
    }
    
    
    @IBAction func backButtonAction() {
        
        // Navigate to the previous view controller.
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func selectButtonAction() {
        
        let vc = CompetitionDetailsVC(
            media: videoAVUrlAsset,
            previewImageTime: seekTime
        )
        navigationController?.pushViewController(
            vc,
            animated: true
        )
    }
    
    
    @IBAction func videoSeekSliderValueChanged(_ sender: UISlider) {
        
        // Seek to a frame in the video based on the slider position.
        if let duration = videoPlayer.currentItem?.duration {
            
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(sender.value) * (totalSeconds / Float64(sender.maximumValue))
            
            // Store the seek time that will be used to generate the preview image.
            seekTime = CMTime(value: Int64(value), timescale: 1)
            videoPlayer.seek(to: seekTime)
        }
    }
    
    
    /// Configure the view to display the video.
    private func configureAVPlayer() {
        
        videoPlayerLayer = AVPlayerLayer()
        videoPlayer = AVPlayer(playerItem: AVPlayerItem(asset: videoAVUrlAsset))
        
        videoPlayerLayer.player = videoPlayer
        videoPlayerLayer.frame = CGRect(origin: .zero, size: videoContainerView.frame.size)
        videoPlayerLayer.videoGravity = .resizeAspect
        
        videoContainerView.layer.addSublayer(videoPlayerLayer)
    }
}
