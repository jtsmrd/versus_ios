//
//  ViewCompetitionVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/26/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class ViewCompetitionVC: UIViewController {
    
    enum VotedCompetition {
        case user1
        case user2
        case none
    }
    
    @IBOutlet weak var competitionTimeRemainingLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var competitionImageContainerView: UIView!
    @IBOutlet weak var competitionImageImageView: UIImageView!
    @IBOutlet weak var competitionVideoContainerView: UIView!
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        
        let imageVoteGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewCompetitionVC.voteForCompetition))
        imageVoteGestureRecognizer.numberOfTapsRequired = 2
        competitionImageContainerView.addGestureRecognizer(imageVoteGestureRecognizer)
        
        let videoVoteGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewCompetitionVC.voteForCompetition))
        videoVoteGestureRecognizer.numberOfTapsRequired = 2
        competitionVideoContainerView.addGestureRecognizer(videoVoteGestureRecognizer)
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
        switch selectedUser {
        case .user1:
            votedCompetition = .user1
        case .user2:
            votedCompetition = .user2
        }
        configureVoteButton()
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
        
        configureVoteButton()
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
                print()
//            competition.getCompetitionImage(for: competitionUser, bucketType: .competitionVideoPreviewImage) { (image, error) in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        self.displayError(error: error)
//                    }
//                    else {
//                        self.competitionImageImageView.image = image
//                    }
//                }
//            }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
