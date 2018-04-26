//
//  ViewCompetitionVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/26/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class ViewCompetitionVC: UIViewController {

    
    @IBOutlet weak var competitionTimeRemainingLabel: UILabel!
    @IBOutlet weak var competitionImageContainerView: UIView!
    @IBOutlet weak var competitionImageImageView: UIImageView!
    @IBOutlet weak var competitionVideoContainerView: UIView!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    @IBOutlet weak var numberOfVotesLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var user1RankImageView: UIImageView!
    @IBOutlet weak var user1UsernameLabel: UILabel!
    @IBOutlet weak var user1SelectorView: CircleView!
    @IBOutlet weak var user1ProfileImageView: UIImageView!
    @IBOutlet weak var user2RankImageView: UIImageView!
    @IBOutlet weak var user2UsernameLabel: UILabel!
    @IBOutlet weak var user2SelectorView: CircleView!
    @IBOutlet weak var user2ProfileImageView: UIImageView!
    
    
    var competition: Competition!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    func initData(competition: Competition) {
        self.competition = competition
    }
    
    
    private func configureView() {
        switch competition.competitionType {
        case .image:
            competitionImageContainerView.isHidden = false
            competitionImageImageView.image = competition.user1CompetitionImage
        case .video:
            competitionVideoContainerView.isHidden = false
        }
        
        user1RankImageView.image = competition.user1RankImage
        user1UsernameLabel.text = competition.user1Username
        
        user2RankImageView.image = competition.user2RankImage
        user2UsernameLabel.text = competition.user2Username
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
