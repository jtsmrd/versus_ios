//
//  CompetitorVC.swift
//  Versus
//
//  Created by JT Smrdel on 8/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AVKit

protocol CompetitorVCDelegate {
    func voteForCompetitor(competitionEntryId: String, competitorType: CompetitorType, isVoteSwitched: Bool)
}

class CompetitorVC: UIViewController {

    private let notificationCenter = NotificationCenter.default
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var competitionImageView: UIImageView!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsViewBottom: NSLayoutConstraint!
    @IBOutlet weak var commentsViewHeight: NSLayoutConstraint!
    
    private var viewSingleTapGestureRecognizer: UITapGestureRecognizer!
    private var viewDoubleTapGestureRecognizer: UITapGestureRecognizer!
    private var originalCommentsViewHeight: CGFloat!
    private var commentsVC: CommentsVC!
    private var competitor: Competitor!
    private var isExpired: Bool!
    private var videoPlayerLayer: AVPlayerLayer!
    private var player: AVPlayer!
    private var delegate: CompetitorVCDelegate?
    
    // When the user votes, configure the vote button and vote
    // gesture recognizer.
    private var vote: Vote? {
        didSet {
            configureVoteButton()
            configureVoteGestureRecognizer()
        }
    }
    
    /**
     Used to determine if the user voted for the selected competitor
    */
    private var userVotedForCompetitor: Bool {
        
        // The user didn't vote at all
        guard let vote = vote else { return false }
        
        // The user voted for this competitor if the competitionEntryId's match
        return vote.competitionEntryId == competitor.competitionEntryId
    }
    
    /**
    Set from ViewCompetitionVC when the user switches between competitors
    to play and pause video.
     */
    var viewIsSelected: Bool = false {
        didSet {
            guard competitor.competitionType == .video else { return }
            if oldValue == false && viewIsSelected {
                player.play()
            }
            else {
                player.pause()
            }
        }
    }
    
    
    /**
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        originalCommentsViewHeight = commentsView.frame.height
        
        notificationCenter.addObserver(
            self,
            selector: #selector(CompetitorVC.userVoteUpdated(notification:)),
            name: NSNotification.Name.OnUserVoteUpdated,
            object: nil
        )
    }
    
    
    /**
     
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if competitor.competitionType == .video {
            videoPlayerLayer.frame = CGRect(
                origin: .zero,
                size: view.frame.size
            )
        }
    }
    
    
    /**
     
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanUpResources()
    }
    
    
    /**
     Initializer method for competitor view
     */
    func initData(
        competitor: Competitor,
        isExpired: Bool,
        delegate: CompetitorVCDelegate
    ) {
        self.competitor = competitor
        self.isExpired = isExpired
        self.delegate = delegate
    }
    
    
    /**
     
     */
    deinit {
        cleanUpResources()
    }
    
    
    // Remove function after finding out where to put clean
    // up code: viewWillDisappear or deinit
    private func cleanUpResources() {
        if competitor.competitionType == .video {
            notificationCenter.removeObserver(player)
            player.pause()
            player.replaceCurrentItem(with: nil)
        }
        notificationCenter.removeObserver(self)
        if competitor.competitionType == .video {
            view.removeGestureRecognizer(viewSingleTapGestureRecognizer)
        }
        
        view.removeGestureRecognizer(viewDoubleTapGestureRecognizer)
    }
    
    
    /**
     Vote for the selected competitor when view is double tapped
     */
    @objc func viewDoubleTapAction(_ sender: UITapGestureRecognizer) {
        voteForCompetitor()
    }
    
    
    /**
    Mute and unmute video audio if media is video
     */
    @objc func viewSingleTapAction(_ sender: UITapGestureRecognizer) {
        
    }
    
    
    /**
     Handler for when the user vote is updated
     */
    @objc func userVoteUpdated(notification: Notification) {
        if let vote = notification.object as? Vote {
            self.vote = vote
        }
    }
    
    
    /**
     
     */
    @IBAction func commentButtonAction() {
//        commentsViewBottom.constant = 0
//        commentsVC.loadCommentsFor(competitionEntryId: competitor.competitionEntryId) // Pass the id when instantiating and let handle loading (when toggled)
    }
    
    
    /**
     Vote for competitor when the vote button is tapped
     */
    @IBAction func voteButtonAction() {
        voteForCompetitor()
    }
    
    
    /**
     Configure the view's initial state
     */
    private func configureView() {
        commentCountLabel.text = String(format: "%d", competitor.commentCount)
        
        if competitor.competitionType == .video {
            
            // Used to mute/ unmute video audio
            viewSingleTapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(CompetitorVC.viewSingleTapAction(_:))
            )
            viewSingleTapGestureRecognizer.numberOfTapsRequired = 1
            view.addGestureRecognizer(viewSingleTapGestureRecognizer)
        }
        
        // Configure the initial state of the vote button
        configureVoteButton()
        
        // Add and configure the vote gesture recognizer
        viewDoubleTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(CompetitorVC.viewDoubleTapAction(_:))
        )
        viewDoubleTapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(viewDoubleTapGestureRecognizer)
        configureVoteGestureRecognizer()
        
        // Configure the view based on competition type
        switch competitor.competitionType {
        case .image:
            configureForImageCompetition()
        case .video:
            configureForVideoCompetition()
        }
    }
    
    
    /**
     Configure the view for an image competition
     */
    private func configureForImageCompetition() {
        
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            self.competitor.getCompetitionImage { [weak self] (image, customError) in
                DispatchQueue.main.async {
                    if let customError = customError {
                        self?.displayError(error: customError)
                    }
                    self?.competitionImageView.image = image
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    
    /**
     Configure the view for a video competition
     */
    private func configureForVideoCompetition() {
        
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            self.competitor.getCompetitionImage { [weak self] (image, customError) in
                DispatchQueue.main.async {
                    if let customError = customError {
                        self?.displayError(error: customError)
                    }
                    self?.competitionImageView.image = image
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        activityIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            self.competitor.getCompetitionVideo { [weak self] (video, customError) in
                DispatchQueue.main.async {
                    if let customError = customError {
                        self?.displayError(error: customError)
                    }
                    if let video = video {
                        self?.player.replaceCurrentItem(with: AVPlayerItem(asset: video))
                        if let viewIsSelected = self?.viewIsSelected, viewIsSelected {
                            self?.player.play()
                        }
                        self?.activityIndicator.stopAnimating()
                        self?.competitionImageView.isHidden = true
                    }
                    else {
                        self?.activityIndicator.stopAnimating()
                        self?.displayMessage(message: "Unable to download competition video")
                    }
                }
            }
        }
    }
    
    
    /**
     Configure the AVPlayer for video competitions
     */
    private func configureAVPlayer() {
        player = AVPlayer()
        videoPlayerLayer = AVPlayerLayer()
        videoPlayerLayer.player = player
        videoPlayerLayer.frame = CGRect(origin: .zero, size: view.frame.size)
        videoPlayerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPlayerLayer)
        
        notificationCenter.addObserver(
            forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: nil
        ) { (notification) in
            self.player.seek(to: kCMTimeZero)
            self.player.play()
        }
    }
    
    
    /**
     Configure the vote button image and vote count label when the user votes
     */
    private func configureVoteButton() {
        DispatchQueue.main.async {
            
            // Set the vote count label
            self.voteCountLabel.text = String(format: "%d", self.competitor.voteCount)
            
            if self.userVotedForCompetitor {
                
                // The user voted for this competitor. Set vote button image
                // to yellow star.
                self.voteButton.setImage(
                    UIImage(named: "Voting-Star"),
                    for: .normal
                )
            }
            else {
                
                // The user didn't vote for this competitor. Set vote button
                // image to white star.
                self.voteButton.setImage(
                    UIImage(named: "Voting-Star-White"),
                    for: .normal
                )
            }
            
            // Disable the vote button if the competition is expired
            // or if the user voted for this competitor.
            if self.isExpired || self.userVotedForCompetitor {
                self.voteButton.isEnabled = false
            }
            else {
                self.voteButton.isEnabled = true
            }
        }
    }
    
    
    /**
     Enable or disable vote gesture recognizer based on the current vote or if
     the competition is expired.
    */
    private func configureVoteGestureRecognizer() {
        
        if isExpired || userVotedForCompetitor {
            viewDoubleTapGestureRecognizer.isEnabled = false
        }
        else {
            viewDoubleTapGestureRecognizer.isEnabled = true
        }
    }

    
    /**
     Handles voting for the selected competitor
     */
    private func voteForCompetitor() {
        
        // If the user already voted, display the change vote alert
        guard vote == nil else {
            displayChangeVoteAlert()
            return
        }
        delegate?.voteForCompetitor(
            competitionEntryId: competitor.competitionEntryId,
            competitorType: competitor.competitorType,
            isVoteSwitched: false
        )
    }
    
    
    /**
     Display a change vote alert if the user already voted
     */
    private func displayChangeVoteAlert() {
        let alertVC = UIAlertController(
            title: "Change Vote?",
            message: "You already voted, do you want to change it?",
            preferredStyle: .alert
        )
        alertVC.addAction(
            UIAlertAction(
                title: "Yes",
                style: .default,
                handler: { (action) in
                    
                    self.delegate?.voteForCompetitor(
                        competitionEntryId: self.competitor.competitionEntryId,
                        competitorType: self.competitor.competitorType,
                        isVoteSwitched: true
                    )
                }
            )
        )
        alertVC.addAction(
            UIAlertAction(
                title: "Leave it",
                style: .cancel,
                handler: nil
            )
        )
        present(alertVC, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let commentsVC = segue.destination as? CommentsVC {
            self.commentsVC = commentsVC
            commentsVC.initData(delegate: self)
        }
    }
}

extension CompetitorVC: CompetitionCommentsVCDelegate {
    
    
    /**
     Hide the comments view by updating the constraint
     TODO: Animate
     */
    func dismissComments() {
        commentsViewBottom.constant = -originalCommentsViewHeight
    }
    
    
    /**
     Move the comments view up when the keyboard is displayed
     TODO: Animate
     */
    func expandCommentsView() {
        commentsViewHeight.constant = view.frame.height - 20
    }
    
    
    /**
     Move the comments view down then the keyboard is dismissed
     TODO: Animate
     */
    func retractCommentsView() {
        commentsViewHeight.constant = originalCommentsViewHeight
    }
}
