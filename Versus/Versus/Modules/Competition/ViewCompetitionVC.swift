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
    
    enum VotedCompetition: String {
        case user1
        case user2
        case none
    }
    
    @IBOutlet weak var competitionTimeRemainingLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var competitionImageContainerView: UIView!
    @IBOutlet weak var competitionImageImageView: UIImageView!
    @IBOutlet weak var competitionVideoContainerView: UIView!
    @IBOutlet weak var competitionVideoPreviewImageView: UIImageView!
    @IBOutlet weak var competitionVideoActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    @IBOutlet weak var numberOfVotesLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var user1RankImageView: UIImageView!
    @IBOutlet weak var user1UsernameLabel: UILabel!
    @IBOutlet weak var user1SelectorButton: ProgressIndicatorButton!
    @IBOutlet weak var user2RankImageView: UIImageView!
    @IBOutlet weak var user2UsernameLabel: UILabel!
    @IBOutlet weak var user2SelectorButton: ProgressIndicatorButton!
    
    @IBOutlet weak var commentsContainerView: UIView!
    @IBOutlet weak var commentsTableView: UITableView!
    
    @IBOutlet weak var optionsContainerView: UIView!
    @IBOutlet weak var competitionShareCollectionView: UICollectionView!
    @IBOutlet weak var competitionOptionsCollectionView: UICollectionView!
    
    
    
    @IBOutlet var user1SelectorButtonHeight: NSLayoutConstraint!
    @IBOutlet var user2SelectorButtonHeight: NSLayoutConstraint!
    
    
    var competition: Competition!
    var selectedUser: CompetitionUser = .user1
    var votedCompetition: VotedCompetition = .none
    let collectionViewSectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    var user1VideoAVUrlAsset: AVURLAsset?
    var user2VideoAVUrlAsset: AVURLAsset?
    var user1CompetitionPlayerLayer: AVPlayerLayer!
    var user2CompetitionPlayerLayer: AVPlayerLayer!
    var user1CompetitionAVPlayer: AVPlayer!
    var user2CompetitionAVPlayer: AVPlayer!
    
    var user1CompetitionAVPlayerObserver: NSObjectProtocol!
    var user2CompetitionAVPlayerObserver: NSObjectProtocol!
    
    var existingCompetitionVote: CompetitionVote?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureCompetitionAVPlayer()
        
        if !competition.isExpired {
            
            let imageVoteGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewCompetitionVC.voteForCompetition))
            imageVoteGestureRecognizer.numberOfTapsRequired = 2
            competitionImageContainerView.addGestureRecognizer(imageVoteGestureRecognizer)
            
            let videoVoteGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewCompetitionVC.voteForCompetition))
            videoVoteGestureRecognizer.numberOfTapsRequired = 2
            competitionVideoContainerView.addGestureRecognizer(videoVoteGestureRecognizer)
        }
        
        
        // If the current user previously voted, set the votedCompetition and update the vote button.
        CompetitionVoteService.instance.getVoteForCompetition(competitionId: competition.awsCompetition._id!) { (competitionVote) in
            if let competitionVote = competitionVote, let id = competitionVote.awsCompetitionVote._votedForCompetitionEntryId {
                self.existingCompetitionVote = competitionVote
                self.votedCompetition = self.competition.awsCompetition._user1CompetitionEntryId! == id ? .user1 : .user2
            }
            DispatchQueue.main.async {
                self.configureVoteButton()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureExpireCountdown()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Resize the player layer to after the views are layed out.
        user1CompetitionPlayerLayer.frame = CGRect(origin: .zero, size: competitionVideoContainerView.frame.size)
        user2CompetitionPlayerLayer.frame = CGRect(origin: .zero, size: competitionVideoContainerView.frame.size)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(user1CompetitionAVPlayerObserver)
        NotificationCenter.default.removeObserver(user2CompetitionAVPlayerObserver)
        user1CompetitionAVPlayer.pause()
        user1CompetitionAVPlayer.replaceCurrentItem(with: nil)
        user2CompetitionAVPlayer.pause()
        user2CompetitionAVPlayer.replaceCurrentItem(with: nil)
    }
    
    func initData(competition: Competition) {
        self.competition = competition
        
        //TODO: Move this down to configure view or elsewhere when download latency is decreased
        switch competition.competitionType {
        case .image:
            
            competition.getCompetitionImage(for: .user1, bucketType: .competitionImage) { (image, error) in
                
            }
            
            competition.getCompetitionImage(for: .user2, bucketType: .competitionImage) { (image, error) in
                
            }
        case .video:
            
            competition.getCompetitionImage(for: .user1, bucketType: .competitionVideoPreviewImage) { (image, error) in
                
            }
            
            competition.getCompetitionImage(for: .user2, bucketType: .competitionVideoPreviewImage) { (image, error) in
                
            }
            
            CompetitionService.instance.getCompetitionVideo(for: .user1, competition: competition) { (asset, error) in
                if let error = error {
                    self.displayError(error: CustomError(error: error, title: "", desc: "Could not download User1 video"))
                }
                else if let asset = asset {
                    self.user1VideoAVUrlAsset = asset
                    DispatchQueue.main.async {
                        self.displayCompetitionMedia()
                    }
                }
            }
            
            CompetitionService.instance.getCompetitionVideo(for: .user2, competition: competition) { (asset, error) in
                if let error = error {
                    self.displayError(error: CustomError(error: error, title: "", desc: "Could not download User2 video"))
                }
                else if let asset = asset {
                    self.user2VideoAVUrlAsset = asset
                }
            }
        }
    }
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func optionsButtonAction() {
        view.bringSubview(toFront: optionsContainerView)
        optionsContainerView.isHidden = false
        optionsButton.isEnabled = false
    }
    
    @IBAction func commentButtonAction() {
        view.bringSubview(toFront: commentsContainerView)
        commentsContainerView.isHidden = false
    }
    
    @IBAction func voteButtonAction() {
       voteForCompetition()
    }
    
    @IBAction func user1SelectorButtonAction() {
        guard selectedUser != .user1 else { return }
        selectedUser = .user1
        user1SelectorButtonHeight.constant = 80
        user2SelectorButtonHeight.constant = 60
        user1SelectorButton.layoutIfNeeded()
        view.bringSubview(toFront: user1SelectorButton)
        displayCompetitionMedia()
        configureVoteButton()
        updateVoteCount()
    }
    
    @IBAction func user2SelectorButtonAction() {
        guard selectedUser != .user2 else { return }
        selectedUser = .user2
        user2SelectorButtonHeight.constant = 80
        user1SelectorButtonHeight.constant = 60
        user2SelectorButton.layoutIfNeeded()
        view.bringSubview(toFront: user2SelectorButton)
        displayCompetitionMedia()
        configureVoteButton()
        updateVoteCount()
    }
    
    @IBAction func hideCommentsButtonAction() {
        commentsContainerView.isHidden = true
        view.endEditing(true)
    }
    
    @IBAction func competitionOptionsCancelButtonAction() {
        optionsContainerView.isHidden = true
        optionsButton.isEnabled = true
    }
    
    
    
    @objc func voteForCompetition() {
        
        guard votedCompetition.rawValue != selectedUser.rawValue else { return }
        
        guard existingCompetitionVote == nil else {
            displayChangeVoteAlert()
            return
        }
        
        var votedForCompetitionEntryId = ""
        
        switch selectedUser {
        case .user1:
            votedCompetition = .user1
            votedForCompetitionEntryId = competition.awsCompetition._user1CompetitionEntryId!
        case .user2:
            votedCompetition = .user2
            votedForCompetitionEntryId = competition.awsCompetition._user2CompetitionEntryId!
        }
        
        CompetitionVoteService.instance.voteForCompetition(
            competitionId: competition.awsCompetition._id!,
            votedForCompetitionEntryId: votedForCompetitionEntryId
        ) { (success) in
            DispatchQueue.main.async {
                if !success {
                    self.displayError(error: CustomError(error: nil, title: "", desc: "Unable to vote, try again."))
                    self.votedCompetition = .none
                }
                self.configureVoteButton()
            }
        }
    }
    
    
    private func displayChangeVoteAlert() {
        
        let alertVC = UIAlertController(title: "Change Vote?", message: "You already voted, do you want to change it?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            CompetitionVoteService.instance.deleteVoteForCompetition(competitionVote: self.existingCompetitionVote!, completion: { (success, customError) in
                DispatchQueue.main.async {
                    if let error = customError {
                        self.displayError(error: error)
                    }
                    else if success {
                        self.existingCompetitionVote = nil
                        self.voteForCompetition()
                    }
                    else {
                        debugPrint("Failed to delete competition vote, something else went wrong.")
                    }
                }
            })
        }))
        alertVC.addAction(UIAlertAction(title: "Leave it", style: .cancel, handler: { (action) in
            
        }))
        present(alertVC, animated: true, completion: nil)
    }
    
    
    private func configureView() {
        switch competition.competitionType {
        case .image:
            competitionImageContainerView.isHidden = false
            competitionVideoContainerView.isHidden = true
        case .video:
            competitionVideoContainerView.isHidden = false
            competitionImageContainerView.isHidden = true
        }
        
        displayCompetitionMedia()
        user1RankImageView.image = competition.userRankImage(for: .user1)
        user1UsernameLabel.text = competition.username(for: .user1)
        user2RankImageView.image = competition.userRankImage(for: .user2)
        user2UsernameLabel.text = competition.username(for: .user2)
        
        competition.getCompetitionImage(for: .user1, bucketType: .profileImageSmall) { (image, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else {
                    self.user1SelectorButton._imageView.image = image
                }
            }
        }
        
        competition.getCompetitionImage(for: .user2, bucketType: .profileImageSmall) { (image, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else {
                    self.user2SelectorButton._imageView.image = image
                }
            }
        }
        
        updateVoteCount()
        
        if competition.isExpired {
            voteButton.isEnabled = false
        }
    }
    
    
    private func updateVoteCount() {
        
        let competitionEntryId = selectedUser == .user1 ? competition.awsCompetition._user1CompetitionEntryId! : competition.awsCompetition._user2CompetitionEntryId!
        
        CompetitionVoteService.instance.getVoteCountFor(competitionEntryId) { (voteCount, customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.displayError(error: customError)
                }
                else if let voteCount = voteCount {
                    self.numberOfVotesLabel.text = "\(voteCount)"
                }
                else {
                    debugPrint("Unknown error when getting votes")
                }
            }
        }
    }
    
    
    private func configureVoteButton() {
        if votedCompetition == .user1 && selectedUser == .user1 {
            voteButton.setImage(UIImage(named: "Voting-Star"), for: .normal)
        }
        else if votedCompetition == .user2 && selectedUser == .user2 {
            voteButton.setImage(UIImage(named: "Voting-Star"), for: .normal)
        }
        else {
            voteButton.setImage(UIImage(named: "Voting-Star-White"), for: .normal)
        }
    }
    
    private func displayCompetitionMedia() {
        
        let competitionUser: CompetitionUser = selectedUser == .user1 ? .user1 : .user2
        
        switch competition.competitionType {
        case .image:
            
            competition.getCompetitionImage(for: competitionUser, bucketType: .competitionImage) { (image, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.displayError(error: error)
                    }
                    else {
                        self.competitionImageImageView.image = image
                    }
                }
            }
            
        case .video:
            
            var videoStillDownloading = false
            var competitionUser: CompetitionUser!
            
            switch selectedUser {
            case .user1:
                
                competitionUser = .user1
                
                if let videoAsset = user1VideoAVUrlAsset {
                    competitionVideoPreviewImageView.isHidden = true
                    
                    if competitionVideoActivityIndicator.isAnimating {
                        competitionVideoActivityIndicator.stopAnimating()
                    }
                    
                    if user1CompetitionAVPlayer.currentItem == nil {
                        user1CompetitionAVPlayer.replaceCurrentItem(with: AVPlayerItem(asset: videoAsset))
                    }
                    
                    toggleCompetiionPlayerLayer(for: .user1)
                    user1CompetitionAVPlayer.play()
                    
                    if user2CompetitionAVPlayer.status == .readyToPlay {
                        user2CompetitionAVPlayer.pause()
                    }
                }
                else {
                    videoStillDownloading = true
                    
                    // The small preview image should already be downloaded from when the competition cell was displayed.
                    // Show the lower quality preview image until the normal/ high quality image is downloaded
                    if let smallPreviewImage = competition.user1CompetitionVideoPreviewImageSmall {
                        competitionVideoActivityIndicator.startAnimating()
                        competitionVideoPreviewImageView.isHidden = false
                        competitionVideoPreviewImageView.image = smallPreviewImage
                    }
                }
                
            case .user2:
                
                competitionUser = .user2
                
                if let videoAsset = user2VideoAVUrlAsset {
                    competitionVideoPreviewImageView.isHidden = true
                    
                    if competitionVideoActivityIndicator.isAnimating {
                        competitionVideoActivityIndicator.stopAnimating()
                    }
                    
                    if user2CompetitionAVPlayer.currentItem == nil {
                        user2CompetitionAVPlayer.replaceCurrentItem(with: AVPlayerItem(asset: videoAsset))
                    }
                    
                    toggleCompetiionPlayerLayer(for: .user2)
                    user2CompetitionAVPlayer.play()
                    
                    if user1CompetitionAVPlayer.status == .readyToPlay {
                        user1CompetitionAVPlayer.pause()
                    }
                }
                else {
                    videoStillDownloading = true
                    
                    if let smallPreviewImage = competition.user2CompetitionVideoPreviewImageSmall {
                        competitionVideoActivityIndicator.startAnimating()
                        competitionVideoPreviewImageView.isHidden = false
                        competitionVideoPreviewImageView.image = smallPreviewImage
                    }
                }
            }
            
            if videoStillDownloading {
                competition.getCompetitionImage(
                    for: competitionUser,
                    bucketType: .competitionVideoPreviewImage
                ) { (image, error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.displayError(error: error)
                        }
                        else {
                            self.competitionVideoActivityIndicator.startAnimating()
                            self.competitionVideoPreviewImageView.isHidden = false
                            self.competitionVideoPreviewImageView.image = image
                        }
                    }
                }
            }
        }
    }
    
    
    private func configureExpireCountdown() {
        
        guard !competition.isExpired else {
            competitionTimeRemainingLabel.text = String(format: "%02i:%02i:%02i:%02i", 0, 0, 0, 0)
            return
        }
        
        guard let secondsUntilExpire = competition.secondsUntilExpire else {
            debugPrint("Could not get competition seconds until expire")
            return
        }
        
        updateExpireCountdown(timeRemaining: secondsUntilExpire)
        
        let countdownTimer = CountdownTimer(countdownSeconds: secondsUntilExpire, delegate: self)
        countdownTimer.start()
    }
    
    private func updateExpireCountdown(timeRemaining: Int) {
        let timeRemainingInterval = TimeInterval(timeRemaining)
        let days = Int(timeRemainingInterval) / 86400
        let hours = (Int(timeRemainingInterval) % 86400) / 3600
        let minutes = (Int(timeRemainingInterval) % 3600) / 60
        let seconds = (Int(timeRemainingInterval) % 60)
        competitionTimeRemainingLabel.text = String(format: "%02i:%02i:%02i:%02i", days, hours, minutes, seconds)
    }
    
    
    private func configureCompetitionAVPlayer() {
        
        user1CompetitionPlayerLayer = AVPlayerLayer()
        user1CompetitionAVPlayer = AVPlayer()
        user1CompetitionPlayerLayer.player = user1CompetitionAVPlayer
        user1CompetitionPlayerLayer.frame = CGRect(origin: .zero, size: competitionVideoContainerView.frame.size)
        user1CompetitionPlayerLayer.videoGravity = .resizeAspectFill
        competitionVideoContainerView.layer.addSublayer(user1CompetitionPlayerLayer)
        
        user2CompetitionPlayerLayer = AVPlayerLayer()
        user2CompetitionAVPlayer = AVPlayer()
        user2CompetitionPlayerLayer.player = user2CompetitionAVPlayer
        user2CompetitionPlayerLayer.frame = CGRect(origin: .zero, size: competitionVideoContainerView.frame.size)
        user2CompetitionPlayerLayer.videoGravity = .resizeAspectFill
        competitionVideoContainerView.layer.addSublayer(user2CompetitionPlayerLayer)
        
        user1CompetitionAVPlayerObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: user1CompetitionAVPlayer.currentItem,
            queue: nil
        ) { (notification) in
            self.user1CompetitionAVPlayer.seek(to: kCMTimeZero)
            self.user1CompetitionAVPlayer.play()
        }
        
        user2CompetitionAVPlayerObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: user2CompetitionAVPlayer.currentItem,
            queue: nil
        ) { (notification) in
            self.user2CompetitionAVPlayer.seek(to: kCMTimeZero)
            self.user2CompetitionAVPlayer.play()
        }
    }
    
    
    private func toggleCompetiionPlayerLayer(for competitionUser: CompetitionUser) {
        
        switch competitionUser {
        case .user1:
            user1CompetitionPlayerLayer.isHidden = false
            user2CompetitionPlayerLayer.isHidden = true
        case .user2:
            user1CompetitionPlayerLayer.isHidden = true
            user2CompetitionPlayerLayer.isHidden = false
        }
    }
    
    
    private func shareToInstagramAction() {
        displayMessage(message: "Share to Instagram")
    }
    
    
    private func shareToMessageAction() {
        displayMessage(message: "Share to Message")
    }
    
    
    private func shareToWhatsAppAction() {
        displayMessage(message: "Share to WhatsApp")
    }
    
    
    private func shareToFacebookMessengerAction() {
        displayMessage(message: "Share to Facebook Messenger")
    }
    
    
    private func optionShareAction() {
        displayMessage(message: "Share")
    }
    
    
    private func optionCopyLinkAction() {
        displayMessage(message: "Copy Link")
    }
    
    
    private func optionReportAction() {
        displayMessage(message: "Report Competition")
    }
}


extension ViewCompetitionVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == competitionShareCollectionView {
            return ShareIconCollection.instance.shareIcons.count
        }
        else if collectionView == competitionOptionsCollectionView {
            return OptionIconCollection.instance.optionIcons.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == competitionShareCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: COMPETITION_SHARE_CELL, for: indexPath) as? CompetitionShareCell {
                cell.configureCell(shareIcon: ShareIconCollection.instance.shareIcons[indexPath.row])
                return cell
            }
            return CompetitionShareCell()
        }
        else if collectionView == competitionOptionsCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: COMPETITION_OPTION_CELL, for: indexPath) as? CompetitionOptionCell {
                cell.configureCell(optionIcon: OptionIconCollection.instance.optionIcons[indexPath.row])
                return cell
            }
            return CompetitionOptionCell()
        }
        return UICollectionViewCell()
    }
}


extension ViewCompetitionVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == competitionShareCollectionView {
            
            let shareIcon = ShareIconCollection.instance.shareIcons[indexPath.row]
            
            switch shareIcon.shareIconType {
            case .instagram:
                shareToInstagramAction()
            case .message:
                shareToMessageAction()
            case .whatsApp:
                shareToWhatsAppAction()
            case .facebookMessenger:
                shareToFacebookMessengerAction()
            }
        }
        else if collectionView == competitionOptionsCollectionView {
            
            let optionIcon = OptionIconCollection.instance.optionIcons[indexPath.row]
            
            switch optionIcon.optionIconType {
            case .share:
                optionShareAction()
            case .copyLink:
                optionCopyLinkAction()
            case .report:
                optionReportAction()
            }
        }
    }
}

extension ViewCompetitionVC: CountdownTimerDelegate {
    
    func timerTick(timeRemaining: Int) {
        updateExpireCountdown(timeRemaining: timeRemaining)
    }
    
    func timerExpired() {
        competitionTimeRemainingLabel.text = String(format: "%02i:%02i:%02i:%02i", 0, 0, 0, 0)
    }
}
