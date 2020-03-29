//
//  EntryVC.swift
//  Versus
//
//  Created by JT Smrdel on 3/24/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import AVKit

protocol EntryVCDelegate: class {
    func viewDoubleTapped()
}

class EntryVC: UIViewController {

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var entryImageView: UIImageView!
    
    private let notificationCenter = NotificationCenter.default
    private let s3BucketService = S3BucketService.instance
    
    private weak var delegate: EntryVCDelegate?
    private var commentsVC: CommentsVC!
    private var videoPlayerLayer: AVPlayerLayer!
    private var player: AVPlayer!
    private var viewSingleTapGestureRecognizer: UITapGestureRecognizer!
    private var viewDoubleTapGestureRecognizer: UITapGestureRecognizer!
    
    private var entry: Entry!
    private var isExpired: Bool!
    
    /**
    Set from ViewCompetitionVC when the user switches between competitors
    to play and pause video.
     */
    // Todo: See if we can use another method for playing/pausing video
    var viewIsSelected: Bool {
        return view.frame.origin.x == 0
    }
    
    
    init(
        entry: Entry,
        isExpired: Bool,
        delegate: EntryVCDelegate?
    ) {
        super.init(nibName: nil, bundle: nil)
        
        self.entry = entry
        self.isExpired = isExpired
        self.delegate = delegate
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        
        configureAVPlayer()
        
        notificationCenter.addObserver(
            self,
            selector: #selector(EntryVC.competitionUpdated(notification:)),
            name: NSNotification.Name.OnCompetitionUpdated,
            object: nil
        )
        
        addObserver(
            self,
            forKeyPath: "view.frame",
            options: [.new],
            context: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoPlayerLayer.frame = CGRect(
            origin: .zero,
            size: view.frame.size
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player.replaceCurrentItem(with: nil)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "view.frame" {
            handleViewToggled()
        }
    }
    
    
    
    /**
     Vote for the selected competitor when view is double tapped
     */
    @objc func viewDoubleTapAction(_ sender: UITapGestureRecognizer) {
        
        // Check isExpired again, since the competition could expire
        // after the view was configured.
        if !isExpired {
            delegate?.viewDoubleTapped()
        }
    }
    
    
    /**
    Mute and unmute video audio if media is video
     */
    @objc func viewSingleTapAction(_ sender: UITapGestureRecognizer) {
        
        if entry.competitionType == .video {
            
            if player.rate != 0 {
                player.pause()
            }
            else {
                player.play()
            }
        }
    }
    
    
    @objc func competitionUpdated(notification: Foundation.Notification) {
        
        if let competition = notification.object as? Competition {
            entry = competition.getEntry(entryId: entry.id)
        }
    }
    
    
    private func handleViewToggled() {
        
        if entry.competitionType == .video {
            
            if viewIsSelected {
                player.play()
            }
            else {
                player.pause()
            }
        }
    }
    
    
    private func configureView() {
        
//        commentCountLabel.text = String(format: "%d", entry.commentCount)
        
        if entry.competitionType == .video {
            
            // Used to mute/ unmute video audio
            viewSingleTapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(EntryVC.viewSingleTapAction(_:))
            )
            viewSingleTapGestureRecognizer.numberOfTapsRequired = 1
            view.addGestureRecognizer(viewSingleTapGestureRecognizer)
        }
        
        // Add vote gesture recognizer if competition isn't expired
        if !isExpired {
            viewDoubleTapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(EntryVC.viewDoubleTapAction(_:))
            )
            viewDoubleTapGestureRecognizer.numberOfTapsRequired = 2
            view.addGestureRecognizer(viewDoubleTapGestureRecognizer)
        }
        
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
    
    
    /**
     Configure the AVPlayer for video competitions
     */
    private func configureAVPlayer() {
        
        player = AVPlayer()
        videoPlayerLayer = AVPlayerLayer()
        videoPlayerLayer.player = player
        videoPlayerLayer.frame = CGRect(
            origin: .zero,
            size: view.frame.size
        )
        videoPlayerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPlayerLayer)
        
        notificationCenter.addObserver(
            forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: nil
        ) { (notification) in
            
            if self.viewIsSelected {
                self.player.seek(to: CMTime.zero)
                self.player.play()
            }
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
        DispatchQueue.global(qos: .userInitiated).async {

            self.s3BucketService.downloadVideo(
                mediaId: self.entry.mediaId,
                bucketType: .video,
                completion: { [weak self] (video, customError) in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {

                        if let customError = customError {
                            self.displayError(error: customError)
                        }

                        if let video = video {
                            
                            self.player.replaceCurrentItem(
                                with: AVPlayerItem(asset: video)
                            )
                            
                            if self.viewIsSelected {
                                self.player.play()
                            }
                            
                            self.activityIndicator.stopAnimating()
                            self.entryImageView.isHidden = true
                        }
                        else {
                            self.activityIndicator.stopAnimating()
                            self.displayMessage(
                                message: "Unable to download competition video"
                            )
                        }
                    }
                }
            )
        }
    }
}
