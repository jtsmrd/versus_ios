//
//  CompetitionVC.swift
//  Versus
//
//  Created by JT Smrdel on 3/24/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

class CompetitionVC: UIViewController {

    
    enum ScreenPosition {
        case center
        case left
        case right
    }
    
    
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var leftEntryRankImageView: UIImageView!
    @IBOutlet weak var leftEntryUsernameLabel: UILabel!
    @IBOutlet weak var leftEntryButton: ProgressIndicatorButton!
    @IBOutlet weak var rightEntryRankImageView: UIImageView!
    @IBOutlet weak var rightEntryUsernameLabel: UILabel!
    @IBOutlet weak var rightEntryButton: ProgressIndicatorButton!
    
    @IBOutlet var leftEntryButtonHeight: NSLayoutConstraint!
    @IBOutlet var rightEntryButtonHeight: NSLayoutConstraint!
    
    private let voteService = VoteService.instance
    private let competitionService = CompetitionService.instance
    private let s3BucketService = S3BucketService.instance
    private let notificationCenter = NotificationCenter.default
    
    private var competition: Competition!
    private var leftEntryVC: EntryVC!
    private var rightEntryVC: EntryVC!
    private var optionsVC: ViewCompetitionOptionsVC!
    
    // TODO
    // Calculate this
    private var selectedEntry: Entry!
    
//    private var optionsViewIsDisplayed: Bool {
//        return optionsViewBottom.constant == 0
//    }
//
//    private var existingVote: Vote? {
//        didSet {
//            if let vote = existingVote {
//                postUserVoteUpdated(vote: vote)
//            }
//        }
//    }
    
    
    
    
    init(competition: Competition) {
        super.init(nibName: nil, bundle: nil)
        
        self.competition = competition
        selectedEntry = competition.leftEntry
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadEntryViewControllers()
        configureExpireCountdown()
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(CompetitionVC.viewTapped)
            )
        )
    }
    
    
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func optionsButtonAction() {
        
        toggleOptionsView()
        optionsButton.isEnabled = false
    }
    
    
    @IBAction func leftEntryButtonAction() {
        
        guard selectedEntry != competition.leftEntry else { return }
        
        selectedEntry = competition.leftEntry
        toggleEntryView(entryType: .left)
        leftEntryButtonHeight.constant = 80.0
        rightEntryButtonHeight.constant = 60.0
        leftEntryButton.layoutIfNeeded()
    }
    
    
    @IBAction func rightEntryButtonAction() {
        
        guard selectedEntry != competition.rightEntry else { return }
        
        selectedEntry = competition.rightEntry
        toggleEntryView(entryType: .right)
        rightEntryButtonHeight.constant = 80.0
        leftEntryButtonHeight.constant = 60.0
        rightEntryButton.layoutIfNeeded()
    }
    
    
    @objc func viewTapped() {
        
//        if optionsViewIsDisplayed {
//            toggleOptionsView()
//        }
    }
    
    
    
    
    private func loadEntryViewControllers() {
        
        leftEntryVC = EntryVC(entry: competition.leftEntry)
        addChild(leftEntryVC)
        leftEntryVC.view.frame = getFrameFor(position: .center)
        view.insertSubview(leftEntryVC.view, at: 0)
        leftEntryVC.didMove(toParent: self)
        
        rightEntryVC = EntryVC(entry: competition.rightEntry)
        addChild(rightEntryVC)
        rightEntryVC.view.frame = getFrameFor(position: .right)
        view.insertSubview(rightEntryVC.view, at: 0)
        rightEntryVC.didMove(toParent: self)
    }
    
    
    private func configureView() {
        
        let leftEntryUser = competition.leftEntry.user
        let rightEntryUser = competition.rightEntry.user
        
        leftEntryRankImageView.image = leftEntryUser.rank.image
        leftEntryUsernameLabel.text = leftEntryUser.username.withAtSignPrefix
        
        rightEntryRankImageView.image = rightEntryUser.rank.image
        rightEntryUsernameLabel.text = rightEntryUser.username.withAtSignPrefix
        
        downloadProfileImage(
            for: leftEntryUser
        ) { [weak self] (image, errorMessage) in
            
            DispatchQueue.main.async {
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                }
                else {
                    self?.leftEntryButton._imageView.image = image
                }
            }
        }
        
        downloadProfileImage(
            for: rightEntryUser
        ) { [weak self] (image, errorMessage) in
            
            DispatchQueue.main.async {
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                }
                else {
                    self?.rightEntryButton._imageView.image = image
                }
            }
        }
    }
    
    
    private func downloadProfileImage(
        for user: User,
        completion: @escaping (_ image: UIImage?, _ errorMessage: String?) -> ()
    ) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.s3BucketService.downloadImage(
                mediaId: user.profileImage,
                imageType: .small,
                completion: completion
            )
        }
    }
    
    
    private func getFrameFor(position: ScreenPosition) -> CGRect {
        
        let screenWidth = UIWindow().bounds.width
        var deltaX: CGFloat = 0.0
        
        switch position {
            
        case .center:
            deltaX = 0.0
            
        case .left:
            deltaX = -(screenWidth)
            
        case .right:
            deltaX = screenWidth
        }
        
        return CGRect(
            x: view.frame.origin.x + deltaX,
            y: view.frame.origin.y,
            width: view.frame.width,
            height: view.frame.height
        )
    }
    
    
    private func configureExpireCountdown() {
        
        guard !competition.isExpired else {
            timeRemainingLabel.text = String(
                format: "%02i:%02i:%02i:%02i", 0, 0, 0, 0
            )
            return
        }
        
        let timeRemaining = competition.secondsUntilExpire
        
//        updateExpireCountdown(timeRemaining: timeRemaining)
        
        let countdownTimer = CountdownTimer(
            countdownSeconds: timeRemaining,
            delegate: self
        )
        countdownTimer.start()
    }
    
    
    private func updateExpireCountdown(timeRemaining: Int) {
        
        let timeRemainingInterval = TimeInterval(timeRemaining)
        let days = Int(timeRemainingInterval) / 86400
        let hours = (Int(timeRemainingInterval) % 86400) / 3600
        let minutes = (Int(timeRemainingInterval) % 3600) / 60
        let seconds = (Int(timeRemainingInterval) % 60)
        
        timeRemainingLabel.text = String(
            format: "%02i:%02i:%02i:%02i",
            days,
            hours,
            minutes,
            seconds
        )
    }
    
    
    // TODO
    private func getVote() {
        
    }
    
    
    private func toggleEntryView(entryType: EntryType) {
        
        switch entryType {
            
        case .left:
            
            // Animate left entry to center and right entry to right
            
            UIView.animate(withDuration: 0.25) {
                
                self.leftEntryVC.view.frame = self.getFrameFor(position: .center)
                self.rightEntryVC.view.frame = self.getFrameFor(position: .right)
                
                self.leftEntryVC.view.layoutIfNeeded()
                self.rightEntryVC.view.layoutIfNeeded()
            }
            
        case .right:
            
            // Animate right entry to center and left entry to left
            
            UIView.animate(withDuration: 0.25) {
                
                self.rightEntryVC.view.frame = self.getFrameFor(position: .center)
                self.leftEntryVC.view.frame = self.getFrameFor(position: .left)
                
                self.rightEntryVC.view.layoutIfNeeded()
                self.leftEntryVC.view.layoutIfNeeded()
            }
        }
    }
    
    
    private func toggleOptionsView() {
        
//        var newConstant: CGFloat = 0
//        if optionsViewIsDisplayed {
//            newConstant = -(optionsView.frame.height)
//            optionsButton.isEnabled = true
//        }
//        optionsViewBottom.constant = newConstant
    }
    
    
    private func postUserVoteUpdated(vote: Vote) {
        
        notificationCenter.post(
            name: NSNotification.Name.OnUserVoteUpdated,
            object: vote
        )
    }
}




extension CompetitionVC: CountdownTimerDelegate {
    
    
    func timerTick(timeRemaining: Int) {
//        updateExpireCountdown(timeRemaining: timeRemaining)
    }
    
    
    func timerExpired() {
        
        timeRemainingLabel.text = String(
            format: "%02i:%02i:%02i:%02i", 0, 0, 0, 0
        )
    }
}
