//
//  ViewCompetitionVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/26/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class ViewCompetitionVC: UIViewController {

    enum SelectedUser {
        case user1
        case user2
    }
    
    @IBOutlet weak var competitionTimeRemainingLabel: UILabel!
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
    
    @IBOutlet var user1SelectorButtonHeight: NSLayoutConstraint!
    @IBOutlet var user2SelectorButtonHeight: NSLayoutConstraint!
    
    
    var competition: Competition!
    var selectedUser: SelectedUser = .user1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    func initData(competition: Competition) {
        self.competition = competition
        
        competition.getUser1CompetitionImage { (image) in
            
        }
        
        competition.getUser2CompetitionImage { (image) in
            
        }
    }
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func optionsButtonAction() {
        
    }
    
    @IBAction func commentButtonAction() {
        
    }
    
    @IBAction func voteButtonAction() {
        
    }
    
    @IBAction func user1SelectorButtonAction() {
        guard selectedUser != .user1 else { return }
        selectedUser = .user1
        user1SelectorButtonHeight.constant = 80
        user2SelectorButtonHeight.constant = 60
        user1SelectorButton.layoutIfNeeded()
        view.bringSubview(toFront: user1SelectorButton)
        displayCompetitionMedia()
    }
    
    @IBAction func user2SelectorButtonAction() {
        guard selectedUser != .user2 else { return }
        selectedUser = .user2
        user2SelectorButtonHeight.constant = 80
        user1SelectorButtonHeight.constant = 60
        user2SelectorButton.layoutIfNeeded()
        view.bringSubview(toFront: user2SelectorButton)
        displayCompetitionMedia()
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
        user1RankImageView.image = competition.user1RankImage
        user1UsernameLabel.text = competition.user1Username
        user2RankImageView.image = competition.user2RankImage
        user2UsernameLabel.text = competition.user2Username
        
        competition.getUser1ProfileImage { (image) in
            DispatchQueue.main.async {
                self.user1SelectorButton._imageView.image = image
            }
        }
        
        competition.getUser2ProfileImage { (image) in
            DispatchQueue.main.async {
                self.user2SelectorButton._imageView.image = image
            }
        }
    }
    
    private func displayCompetitionMedia() {
        switch selectedUser {
        case .user1:
            switch competition.competitionType {
            case .image:
                competition.getUser1CompetitionImage { (image) in
                    DispatchQueue.main.async {
                        self.competitionImageImageView.image = image
                    }
                }
            case .video:
                print()
            }
        case .user2:
            switch competition.competitionType {
            case .image:
                competition.getUser2CompetitionImage { (image) in
                    DispatchQueue.main.async {
                        self.competitionImageImageView.image = image
                    }
                }
            case .video:
                print()
            }
        }
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
