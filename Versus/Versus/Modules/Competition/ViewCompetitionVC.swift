//
//  ViewCompetitionVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/26/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AVKit

class ViewCompetitionVC: UIViewController {
    
    
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var firstCompetitorRankImageView: UIImageView!
    @IBOutlet weak var firstCompetitorUsernameLabel: UILabel!
    @IBOutlet weak var firstCompetitorSelectorButton: ProgressIndicatorButton!
    @IBOutlet weak var secondCompetitorRankImageView: UIImageView!
    @IBOutlet weak var secondCompetitorUsernameLabel: UILabel!
    @IBOutlet weak var secondCompetitorSelectorButton: ProgressIndicatorButton!
    @IBOutlet weak var firstCompetitorView: UIView!
    @IBOutlet weak var secondCompetitorView: UIView!
    @IBOutlet weak var optionsView: UIView!
    
    @IBOutlet var firstCompetitorSelectorButtonHeight: NSLayoutConstraint!
    @IBOutlet var secondCompetitorSelectorButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var optionsViewBottom: NSLayoutConstraint!
    
    private let voteService = VoteService.instance
    private let competitionService = CompetitionService.instance
    private let s3BucketService = S3BucketService.instance
    private let notificationCenter = NotificationCenter.default
    
    private var competition: Competition!
    private var selectedEntry: Entry!
    private var firstCompetitorVC: CompetitorVC!
    private var secondCompetitorVC: CompetitorVC!
    private var viewCompetitionOptionsVC: ViewCompetitionOptionsVC!
    private var viewSingleTapGestureRecognizer: UITapGestureRecognizer!
    private var optionsViewIsDisplayed: Bool {
        return optionsViewBottom.constant == 0
    }
    private var existingVote: Vote? {
        didSet {
            if let vote = existingVote {
//                postUserVoteUpdated(vote: vote)
            }
        }
    }
    
    
    /**
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureExpireCountdown()
        getVote()
    }
    
    
    /**
     
     */
    func initData(competition: Competition) {
        self.competition = competition
        selectedEntry = competition.leftEntry
    }
    
    
    /**
     
     */
    deinit {
        view.removeGestureRecognizer(viewSingleTapGestureRecognizer)
    }
    
    
    /**
     
     */
    @objc func viewSingleTapAction(_ sender: UITapGestureRecognizer) {
        if optionsViewIsDisplayed {
            toggleOptionsView()
        }
    }
    
    
    /**
     
     */
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    /**
     
     */
    @IBAction func optionsButtonAction() {
        toggleOptionsView()
        optionsButton.isEnabled = false
    }
    
    
    /**
     
     */
    @IBAction func user1SelectorButtonAction() {
        
        guard selectedEntry != competition.leftEntry else { return }
        selectedEntry = competition.leftEntry
        toggleCompetitorView(.first)
        firstCompetitorSelectorButtonHeight.constant = 80
        secondCompetitorSelectorButtonHeight.constant = 60
        firstCompetitorSelectorButton.layoutIfNeeded()
    }
    
    
    /**
     
     */
    @IBAction func secondCompetitorSelectorButtonAction() {
        guard selectedEntry != competition.rightEntry else { return }
        selectedEntry = competition.rightEntry
        toggleCompetitorView(.second)
        secondCompetitorSelectorButtonHeight.constant = 80
        firstCompetitorSelectorButtonHeight.constant = 60
        secondCompetitorSelectorButton.layoutIfNeeded()
    }
    
    
    /**
     
     */
    private func toggleCompetitorView(_ competitorType: CompetitorType) {
        switch competitorType {
        case .first:
            view.insertSubview(firstCompetitorSelectorButton, aboveSubview: secondCompetitorSelectorButton)
            view.insertSubview(firstCompetitorView, aboveSubview: secondCompetitorView)
//            firstCompetitorVC.viewIsSelected = true
//            secondCompetitorVC.viewIsSelected = false
        case .second:
            view.insertSubview(secondCompetitorSelectorButton, aboveSubview: firstCompetitorSelectorButton)
            view.insertSubview(secondCompetitorView, aboveSubview: firstCompetitorView)
//            secondCompetitorVC.viewIsSelected = true
//            firstCompetitorVC.viewIsSelected = false
        default:
            break
        }
    }
    
    
    /**
     
     */
    private func toggleOptionsView() {
        var newConstant: CGFloat = 0
        if optionsViewIsDisplayed {
            newConstant = -(optionsView.frame.height)
            optionsButton.isEnabled = true
        }
        optionsViewBottom.constant = newConstant
    }
    
    
    /**
     
     */
    private func getVote() {
        // TODO
//        voteService.getVoteForCompetition(
//            competitionId: competition.competitionId
//        ) { [weak self] (vote) in
//            if let vote = vote {
//                self?.existingVote = vote
//            }
//        }
    }
    
    
    /**
     
     */
    private func configureView() {
        // TODO
        firstCompetitorRankImageView.image = nil
        firstCompetitorUsernameLabel.text = String(format: "@%@", competition.leftEntry.user.username)
        secondCompetitorRankImageView.image = nil
        secondCompetitorUsernameLabel.text = String(format: "@%@", competition.rightEntry.user.username)
        
        // TODO: Remove and load using operation queue.
        DispatchQueue.global(qos: .userInitiated).async {
            
            S3BucketService.instance.downloadImage(mediaId: self.competition.leftEntry.user.profileImage, imageType: .small) { [weak self] (image, customError) in
                
                DispatchQueue.main.async {
                    self?.firstCompetitorSelectorButton._imageView.image = image
                }
            }
        }
        
        // TODO: Remove and load using operation queue.
        DispatchQueue.global(qos: .userInitiated).async {
            
            S3BucketService.instance.downloadImage(mediaId: self.competition.rightEntry.user.profileImage, imageType: .small) { [weak self] (image, customError) in
                
                DispatchQueue.main.async {
                    self?.secondCompetitorSelectorButton._imageView.image = image
                }
            }
        }
        
        // Used to dismiss comments VC and options VC
        viewSingleTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ViewCompetitionVC.viewSingleTapAction(_:))
        )
        viewSingleTapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(viewSingleTapGestureRecognizer)
    }
    
    
    /**
     
     */
    private func configureExpireCountdown() {
        
        guard !competition.isExpired else {
            timeRemainingLabel.text = String(format: "%02i:%02i:%02i:%02i", 0, 0, 0, 0)
            return
        }
        
        let timeRemaining = competition.secondsUntilExpire
        
        updateExpireCountdown(timeRemaining: timeRemaining)
        
        let countdownTimer = CountdownTimer(
            countdownSeconds: timeRemaining,
            delegate: self
        )
        countdownTimer.start()
    }
    
    
    /**
     
     */
    private func updateExpireCountdown(timeRemaining: Int) {
        let timeRemainingInterval = TimeInterval(timeRemaining)
        let days = Int(timeRemainingInterval) / 86400
        let hours = (Int(timeRemainingInterval) % 86400) / 3600
        let minutes = (Int(timeRemainingInterval) % 3600) / 60
        let seconds = (Int(timeRemainingInterval) % 60)
        timeRemainingLabel.text = String(format: "%02i:%02i:%02i:%02i", days, hours, minutes, seconds)
    }
    
    
    /**
 
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if segue.identifier == FIRST_COMPETITOR {
//            firstCompetitorVC = segue.destination as! CompetitorVC
//            firstCompetitorVC.initData(
//                competitor: competition.firstCompetitor,
//                isExpired: competition.isExpired,
//                delegate: self
//            )
//        }
//        else if segue.identifier == SECOND_COMPETITOR {
//            secondCompetitorVC = segue.destination as! CompetitorVC
//            secondCompetitorVC.initData(
//                competitor: competition.secondCompetitor,
//                isExpired: competition.isExpired,
//                delegate: self
//            )
//        }
//        else if let viewCompetitionOptionsVC = segue.destination as? ViewCompetitionOptionsVC {
//            viewCompetitionOptionsVC.initData(delegate: self)
//            self.viewCompetitionOptionsVC = viewCompetitionOptionsVC
//        }
    }
}

extension ViewCompetitionVC: CompetitorVCDelegate {
    
    func voteForCompetitor(
        entryId: Int,
        competitionId: Int
    ) {
        voteService.voteForEntry(
            entryId: entryId,
            competitionId: competitionId
        ) { [weak self] (vote, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.displayMessage(message: error)
                return
            }
            self.existingVote = vote
        }
    }
}

extension ViewCompetitionVC: CountdownTimerDelegate {
    
    
    /**
     
     */
    func timerTick(timeRemaining: Int) {
        updateExpireCountdown(timeRemaining: timeRemaining)
    }
    
    
    /**
     
     */
    func timerExpired() {
        timeRemainingLabel.text = String(format: "%02i:%02i:%02i:%02i", 0, 0, 0, 0)
    }
}

extension ViewCompetitionVC: ViewCompetitionOptionsVCDelegate {
    
    
    /**
     
     */
    func dismissOptionsView() {
        toggleOptionsView()
    }
}
