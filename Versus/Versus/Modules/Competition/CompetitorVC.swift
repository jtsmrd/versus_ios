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
    private var vote: Vote? {
        didSet {
            configureVoteButton()
        }
    }
    private var userVotedForCompetitor: Bool {
        guard let vote = vote else { return false }
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
            selector: #selector(userVoteUpdated(notification:)),
            name: NSNotification.Name.OnUserVoteUpdated,
            object: nil
        )
    }
    
    
    /**
     
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if competitor.competitionType == .video {
            videoPlayerLayer.frame = CGRect(origin: .zero, size: view.frame.size)
        }
    }
    
    
    /**
     
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanUpResources()
    }
    
    
    /**
     
     */
    func initData(competitor: Competitor, isExpired: Bool, delegate: CompetitorVCDelegate) {
        self.competitor = competitor
        self.isExpired = isExpired
        self.delegate = delegate
    }
    
    
    /**
     
     */
    deinit {
        cleanUpResources()
    }
    
    
    // Remove function after finding out where to put clean up code: viewWillDisappear or deinit
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
     
     */
    @objc func userVoteUpdated(notification: Notification) {
        if let vote = notification.object as? Vote {
            self.vote = vote
        }
        DispatchQueue.main.async {
            if self.isExpired || self.userVotedForCompetitor {
                self.viewDoubleTapGestureRecognizer.isEnabled = false
                self.voteButton.isEnabled = false
            }
            else {
                self.viewDoubleTapGestureRecognizer.isEnabled = true
                self.voteButton.isEnabled = true
            }
        }
    }
    
    
    /**
     
     */
    @IBAction func commentButtonAction() {
//        commentsViewBottom.constant = 0
//        commentsVC.loadCommentsFor(competitionEntryId: competitor.competitionEntryId) // Pass the id when instantiating and let handle loading (when toggled)
    }
    
    
    /**
     
     */
    @IBAction func voteButtonAction() {
        voteForCompetitor()
    }
    
    
    /**
     
     */
    private func configureView() {
        commentCountLabel.text = String(format: "%d", competitor.commentCount)
        configureVoteButton()
        
        if competitor.competitionType == .video {
            
            // Used to mute/ unmute video audio
            viewSingleTapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(CompetitorVC.viewSingleTapAction(_:))
            )
            viewSingleTapGestureRecognizer.numberOfTapsRequired = 1
            view.addGestureRecognizer(viewSingleTapGestureRecognizer)
        }
        
        // Used to vote for the active competitor
        viewDoubleTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(CompetitorVC.viewDoubleTapAction(_:))
        )
        viewDoubleTapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(viewDoubleTapGestureRecognizer)
        
        switch competitor.competitionType {
        case .image:
            configureForImageCompetition()
        case .video:
            configureForVideoCompetition()
        }
    }
    
    
    /**
     
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
     
     */
    private func configureVoteButton() {
        DispatchQueue.main.async {
            self.voteCountLabel.text = String(format: "%d", self.competitor.voteCount)
            if self.userVotedForCompetitor {
                self.voteButton.setImage(UIImage(named: "Voting-Star"), for: .normal)
            }
            else {
                self.voteButton.setImage(UIImage(named: "Voting-Star-White"), for: .normal)
            }
        }
    }

    
    /**
     
     */
    private func voteForCompetitor() {
        guard vote == nil else {
            displayChangeVoteAlert()
            return
        }
        delegate?.voteForCompetitor(
            competitionEntryId: competitor.competitionEntryId,
            competitorType: competitor.competitorType,
            isVoteSwitched: false
        )
        
//        voteService.voteForCompetition(
//            competitionId: competitor.competitionId,
//            competitionEntryId: competitor.competitionEntryId,
//            competitorType: competitor.competitorType
//        ) { [weak self] (vote, customError) in
//            DispatchQueue.main.async {
//                if let customError = customError {
//                    self?.displayError(error: customError)
//                    return
//                }
//                self?.isNewVote = true
//                self?.incrementVoteCountForCurrentUser()
//                self?.notificationCenter.post(
//                    name: NSNotification.Name.OnUserVoteUpdated,
//                    object: vote
//                )
//            }
//        }
    }
    
    
    /**
     
     */
    private func incrementVoteCountForCurrentUser() {
        CurrentUser.incrementVoteCount()
        CurrentUser.update { [weak self] (customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self?.displayError(error: customError)
                }
            }
        }
    }
    
    
    /**
     
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
                    guard let _ = self.vote else { return }
                    self.delegate?.voteForCompetitor(
                        competitionEntryId: self.competitor.competitionEntryId,
                        competitorType: self.competitor.competitorType,
                        isVoteSwitched: true
                    )
//                    vote.changeVote(
//                        competitionEntryId: self.competitor.competitionEntryId,
//                        competitorType: self.competitor.competitorType,
//                        completion: { [weak self] (vote, customError) in
//                            DispatchQueue.main.async {
//                                if let customError = customError {
//                                    self?.displayError(error: customError)
//                                    return
//                                }
//                                self?.isNewVote = true
//                                self?.notificationCenter.post(
//                                    name: NSNotification.Name.OnUserVoteUpdated,
//                                    object: vote
//                                )
//                            }
//                        }
//                    )
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
 
     */
    func dismissComments() {
        commentsViewBottom.constant = -originalCommentsViewHeight
    }
    
    
    /**
     
     */
    func expandCommentsView() {
        commentsViewHeight.constant = view.frame.height - 20
    }
    
    
    /**
     
     */
    func retractCommentsView() {
        commentsViewHeight.constant = originalCommentsViewHeight
    }
}
