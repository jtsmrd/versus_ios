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
    
    // MARK: - Outlets
    
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var leftEntryRankImageView: UIImageView!
    @IBOutlet weak var leftEntryUsernameLabel: UILabel!
    @IBOutlet weak var leftEntryButton: ProgressIndicatorButton!
    @IBOutlet weak var rightEntryRankImageView: UIImageView!
    @IBOutlet weak var rightEntryUsernameLabel: UILabel!
    @IBOutlet weak var rightEntryButton: ProgressIndicatorButton!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    
    @IBOutlet var leftEntryButtonHeight: NSLayoutConstraint!
    @IBOutlet var rightEntryButtonHeight: NSLayoutConstraint!
    
    private let voteService = VoteService.instance
    private let competitionService = CompetitionService.instance
    private let s3BucketService = S3BucketService.instance
    private let notificationCenter = NotificationCenter.default
    
    private var leftEntryVC: EntryVC!
    private var rightEntryVC: EntryVC!
    private var optionsVC: ViewCompetitionOptionsVC!
    
    // TODO
    // Calculate this
    private var selectedEntry: Entry! {
        didSet {
            configureVoteButton()
        }
    }
    
//    private var optionsViewIsDisplayed: Bool {
//        return optionsViewBottom.constant == 0
//    }
    
    private var competition: Competition! {
        didSet {
            postCompetitionUpdated(competition: self.competition)
            updateSelectedEntryData(competition: self.competition)
        }
    }
    
    private var vote: Vote? {
        didSet {
            if self.vote != nil {
                reloadCompetition()
            }
            configureVoteButton()
        }
    }
    
    
    
    // MARK: - Initializers
    
    init(competition: Competition) {
        super.init(nibName: nil, bundle: nil)
        
        self.competition = competition
        selectedEntry = competition.leftEntry
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        
        loadEntryViewControllers()
        
        configureExpireCountdown()
        
        getVote()
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(CompetitionVC.viewTapped)
            )
        )
    }
    
    
    
    // MARK: - Actions
    
    @IBAction func backButtonAction() {
        
        // This handles a weird animation that happens when the right
        // entry view is selected and the user navigates back.
        if selectedEntry == competition.rightEntry {
            toggleEntryView(entryType: .left, animated: false)
        }
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
        view.bringSubviewToFront(leftEntryButton)
    }
    
    
    @IBAction func rightEntryButtonAction() {
        
        guard selectedEntry != competition.rightEntry else { return }
        
        selectedEntry = competition.rightEntry
        toggleEntryView(entryType: .right)
        rightEntryButtonHeight.constant = 80.0
        leftEntryButtonHeight.constant = 60.0
        rightEntryButton.layoutIfNeeded()
        view.bringSubviewToFront(rightEntryButton)
    }
    
    
    @IBAction func voteButtonAction() {
        voteForCompetitor()
    }
    
    
    @IBAction func commentButtonAction() {
        
    }
    
    
    @objc func viewTapped() {
        
//        if optionsViewIsDisplayed {
//            toggleOptionsView()
//        }
    }
    
    
    
    
    private func loadEntryViewControllers() {
        
        leftEntryVC = EntryVC(
            entry: competition.leftEntry,
            delegate: self
        )
        addChild(leftEntryVC)
        leftEntryVC.view.frame = getFrameFor(position: .center)
        view.insertSubview(leftEntryVC.view, at: 0)
        leftEntryVC.didMove(toParent: self)
        
        rightEntryVC = EntryVC(
            entry: competition.rightEntry,
            delegate: self
        )
        addChild(rightEntryVC)
        rightEntryVC.view.frame = getFrameFor(position: .right)
        view.insertSubview(rightEntryVC.view, at: 0)
        rightEntryVC.didMove(toParent: self)
    }
    
    
    private func configureView() {
        
        configureVoteButton()
        
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
    
    
    /**
     Used to determine if the user voted for the selected competitor
    */
    private var userVotedForCompetitor: Bool {
        
        // The user didn't vote at all
        guard let vote = vote else { return false }
        
        // The user voted for this competitor if the competitionEntryId's match
        return vote.entryId == selectedEntry.id
    }
    
    
    /**
     Configure the vote button image and vote count label when the user votes
     */
    private func configureVoteButton() {
        
        // Set the vote count label
        voteCountLabel.text = String(
            format: "%d",
            selectedEntry.voteCount
        )
        
        if userVotedForCompetitor {
            
            // The user voted for this competitor. Set vote button image
            // to yellow star.
            voteButton.setImage(
                UIImage(named: "Voting-Star"),
                for: .normal
            )
        }
        else {
            
            // The user didn't vote for this competitor. Set vote button
            // image to white star.
            voteButton.setImage(
                UIImage(named: "Voting-Star-White"),
                for: .normal
            )
        }
        
        // Disable the vote button if the competition is expired
        // or if the user voted for this competitor.
        // if self.isExpired || self.userVotedForCompetitor {
        if userVotedForCompetitor {
            voteButton.isUserInteractionEnabled = false
        }
        else {
            voteButton.isUserInteractionEnabled = true
        }
    }
    
    
    private func downloadProfileImage(
        for user: User,
        completion: @escaping (_ image: UIImage?, _ errorMessage: String?) -> ()
    ) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.s3BucketService.downloadImage(
                mediaId: user.profileImage,
                imageType: .regular,
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
    
    
    private func reloadCompetition() {
        
        competitionService.getCompetition(
            competitionId: competition.id
        ) { [weak self] (competition, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.view.makeToast(error)
                }
                else if let competition = competition {
                    self.competition = competition
                }
                else {
                    self.view.makeToast("Unable to load competition.")
                }
            }
        }
    }
    
    
    private func getVote() {
        
        voteService.getVoteForCompetition(
            competitionId: competition.id
        ) { [weak self] (vote, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.view.makeToast(error)
                }
                else if let vote = vote {
                    self.vote = vote
                }
                
                self.configureVoteButton()
            }
        }
    }
    
    
    /**
     Handles voting for the selected competitor
     */
    private func voteForCompetitor() {
        
        // If the user already voted, display the change vote alert
        if let vote = vote {
            displayChangeVoteAlert(vote: vote)
        }
        else {
            createVoteForEntry(entryId: selectedEntry.id)
        }
    }
    
    
    private func createVoteForEntry(entryId: Int) {
        
        voteService.voteForEntry(
            entryId: entryId,
            competitionId: competition.id
        ) { [weak self] (vote, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.view.makeToast(error)
                }
                else if let vote = vote {
                    self.vote = vote
                }
            }
        }
    }
    
    
    private func updateVoteForEntry(vote: Vote, entryId: Int) {
        
        voteService.updateVote(
            voteId: vote.id,
            entryId: entryId
        ) { [weak self] (vote, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.view.makeToast(error)
                }
                else if let vote = vote {
                    self.vote = vote
                }
            }
        }
    }
    
    
    private func updateSelectedEntryData(competition: Competition) {
        
        if selectedEntry.id == competition.leftEntry.id {
            selectedEntry = competition.leftEntry
        }
        else if selectedEntry.id == competition.rightEntry.id {
            selectedEntry = competition.rightEntry
        }
    }
    
    
    /**
     Display a change vote alert if the user already voted
     */
    private func displayChangeVoteAlert(vote: Vote) {
        
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
                    
                    self.updateVoteForEntry(
                        vote: vote,
                        entryId: self.selectedEntry.id
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
    
    
    private func postCompetitionUpdated(competition: Competition) {
        
        notificationCenter.post(
            name: NSNotification.Name.OnCompetitionUpdated,
            object: competition
        )
    }
    
    
    private func toggleEntryView(entryType: EntryType, animated: Bool = true) {
        
        let animationDuration = animated ? 0.25 : 0
        
        switch entryType {
            
        case .left:
            
            // Animate left entry to center and right entry to right
            
            UIView.animate(withDuration: animationDuration) {
                
                self.leftEntryVC.view.frame = self.getFrameFor(position: .center)
                self.rightEntryVC.view.frame = self.getFrameFor(position: .right)
                
                self.leftEntryVC.view.layoutIfNeeded()
                self.rightEntryVC.view.layoutIfNeeded()
            }
            
        case .right:
            
            // Animate right entry to center and left entry to left
            
            UIView.animate(withDuration: animationDuration) {
                
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


extension CompetitionVC: EntryVCDelegate {
    
    func viewDoubleTapped() {
        
        // Don't allow the user to attempt to vote twice.
        guard vote?.entryId != selectedEntry.id else { return }

        voteForCompetitor()
    }
}
