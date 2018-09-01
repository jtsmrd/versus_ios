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
    
    var videoAVUrlAsset: AVURLAsset!
    var videoPlayerLayer: AVPlayerLayer!
    var videoPlayer: AVPlayer!
    var seekTime = CMTimeMakeWithSeconds(0, 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureAVPlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Resize the player layer to after the views are layed out.
        videoPlayerLayer.frame = CGRect(origin: .zero, size: videoContainerView.frame.size)
    }
    
    
    func initData(videoAVUrlAsset: AVURLAsset) {
        self.videoAVUrlAsset = videoAVUrlAsset
    }
    

    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectButtonAction() {
        let previewImage = generatePreviewImage()
        performSegue(withIdentifier: SHOW_COMPETITION_DETAILS, sender: previewImage)
    }
    
    @IBAction func videoSeekSliderValueChanged(_ sender: UISlider) {
        if let duration = videoPlayer.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(sender.value) * (totalSeconds / Float64(sender.maximumValue))
            seekTime = CMTime(value: Int64(value), timescale: 1)
            videoPlayer.seek(to: seekTime)
        }
    }
    
    private func configureAVPlayer() {
        videoPlayerLayer = AVPlayerLayer()
        videoPlayer = AVPlayer(playerItem: AVPlayerItem(asset: videoAVUrlAsset))
        videoPlayerLayer.player = videoPlayer
        videoPlayerLayer.frame = CGRect(origin: .zero, size: videoContainerView.frame.size)
        videoPlayerLayer.videoGravity = .resizeAspectFill
        videoContainerView.layer.addSublayer(videoPlayerLayer)
    }
    
    private func generatePreviewImage() -> UIImage {
        let assetImageGenerator = AVAssetImageGenerator(asset: videoAVUrlAsset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        assetImageGenerator.requestedTimeToleranceAfter = kCMTimeZero
        assetImageGenerator.requestedTimeToleranceBefore = kCMTimeZero
        
        var cgImage: CGImage!
        do {
            cgImage = try assetImageGenerator.copyCGImage(at: seekTime, actualTime: nil)
        }
        catch {
            debugPrint("Error generating preview image")
        }
        return UIImage(cgImage: cgImage)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let competitionDetailsVC = segue.destination as? CompetitionDetailsVC,
            let previewImage = sender as? UIImage {
            competitionDetailsVC.initData(image: previewImage, video: videoAVUrlAsset)
        }
    }
}
