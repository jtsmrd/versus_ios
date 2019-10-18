//
//  EntryVC.swift
//  Versus
//
//  Created by JT Smrdel on 3/24/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import AVKit

class EntryVC: UIViewController {

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var voteCountLabel: UILabel!
    
    private let notificationCenter = NotificationCenter.default
    private let s3BucketService = S3BucketService.instance
    
    private var entry: Entry!
    private var commentsVC: CommentsVC!
    private var videoPlayerLayer: AVPlayerLayer!
    private var player: AVPlayer!
    private var viewSingleTapGestureRecognizer: UITapGestureRecognizer!
    private var viewDoubleTapGestureRecognizer: UITapGestureRecognizer!
    
    
    
    
    init(entry: Entry) {
        super.init(nibName: nil, bundle: nil)
        
        self.entry = entry
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    
    
    
    private func configureView() {
        
//        commentCountLabel.text = String(format: "%d", entry.commentCount)
        
        if entry.competitionType == .video {
            
            // Used to mute/ unmute video audio
            viewSingleTapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(CompetitorVC.viewSingleTapAction(_:))
            )
            viewSingleTapGestureRecognizer.numberOfTapsRequired = 1
            view.addGestureRecognizer(viewSingleTapGestureRecognizer)
        }
        
        // Configure the initial state of the vote button
//        configureVoteButton()
        
        // Add and configure the vote gesture recognizer
        viewDoubleTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(CompetitorVC.viewDoubleTapAction(_:))
        )
        viewDoubleTapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(viewDoubleTapGestureRecognizer)
//        configureVoteGestureRecognizer()
        
        // Configure the view based on competition type
        switch entry.competitionType {
            
        case .image:
            configureForImageCompetition()
            
        case .video:
            configureForVideoCompetition()
            
        default:
            break
        }
    }
    
    
    private func configureForImageCompetition() {
        
        activityIndicator.startAnimating()
        
        // TODO: Remove and user operation queue.
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.s3BucketService.downloadImage(
                mediaId: self.entry.mediaId,
                imageType: .regular,
                completion: { [weak self] (image, customError) in
                
                    DispatchQueue.main.async {
                        self?.entryImageView.image = image
                        self?.activityIndicator.stopAnimating()
                    }
                }
            )
        }
    }
    
    
    private func configureForVideoCompetition() {
        
        activityIndicator.startAnimating()
        
        
        // TODO: Remove and user operation queue.
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.s3BucketService.downloadImage(
                mediaId: self.entry.mediaId,
                imageType: .regular,
                completion: { [weak self] (image, customError) in
                
                    DispatchQueue.main.async {
                        self?.entryImageView.image = image
                        self?.activityIndicator.stopAnimating()
                    }
                }
            )
        }
        
        activityIndicator.startAnimating()
        
        // TODO: Remove and user operation queue.
//        DispatchQueue.global(qos: .userInitiated).async {
//
//            S3BucketService.instance.downloadVideo(mediaId: self.competitor.mediaId, bucketType: .video, completion: { [weak self] (video, customError) in
//
//                DispatchQueue.main.async {
//
//                    if let customError = customError {
//                        self?.displayError(error: customError)
//                    }
//
//                    if let video = video {
//                        self?.player.replaceCurrentItem(with: AVPlayerItem(asset: video))
//                        if let viewIsSelected = self?.viewIsSelected, viewIsSelected {
//                            self?.player.play()
//                        }
//                        self?.activityIndicator.stopAnimating()
//                        self?.competitionImageView.isHidden = true
//                    }
//                    else {
//                        self?.activityIndicator.stopAnimating()
//                        self?.displayMessage(message: "Unable to download competition video")
//                    }
//                }
//            })
//        }
    }
}
