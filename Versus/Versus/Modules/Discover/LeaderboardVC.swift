//
//  LeaderboardVC.swift
//  Versus
//
//  Created by JT Smrdel on 6/29/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class LeaderboardVC: UIViewController {

    
    @IBOutlet weak var leaderboardLabel: UILabel!
    @IBOutlet weak var leadersTableView: UITableView!
    
    
    private let leaderService = LeaderService.instance
    private let LEADERBOARD_HEADER_IMAGE_CELL_HEIGHT: CGFloat = 100
    private let LEADER_CELL_HEIGHT: CGFloat = 70
    
    
    private var leaderboard: Leaderboard!
    private var leaders = [Leader]()
    
    
    
    init(leaderboard: Leaderboard) {
        super.init(nibName: nil, bundle: nil)
        
        self.leaderboard = leaderboard
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        getLeaders()
    }
    
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    private func configureView() {
        
        leaderboardLabel.text = String(
            format: "%@ Leaders",
            leaderboard.type.name
        )
        
        leadersTableView.register(
            UINib(nibName: LEADERBOARD_HEADER_IMAGE_CELL, bundle: nil),
            forCellReuseIdentifier: LEADERBOARD_HEADER_IMAGE_CELL
        )
        
        leadersTableView.register(
            UINib(nibName: LEADER_CELL, bundle: nil),
            forCellReuseIdentifier: LEADER_CELL
        )
    }
    
    
    private func getLeaders() {
        
        switch leaderboard.type.typeEnum {
        case .weekly:
            getWeeklyLeaders()
            
        case .monthly:
            getMonthlyLeaders()
            
        case .allTime:
            getAllTimeLeaders()
        }
    }
    
    private func getWeeklyLeaders() {
        
        leaderService.getWeeklyLeaders { (leaders, error) in
            
            DispatchQueue.main.async {
                if let error = error {
                    self.view.makeToast(error)
                }
                self.leaders = leaders
                self.leadersTableView.reloadData()
            }
        }
    }
    
    private func getMonthlyLeaders() {
        
        leaderService.getMonthlyLeaders { [weak self] (leaders, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.displayMessage(message: error)
                }
                
                self.leaders = leaders
                self.leadersTableView.reloadData()
            }
        }
    }
    
    private func getAllTimeLeaders() {
        
        leaderService.getAllTimeLeaders { [weak self] (leaders, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.displayMessage(message: error)
                }
                
                self.leaders = leaders
                self.leadersTableView.reloadData()
            }
        }
    }
    
    
    private func showLeaderProfile(leader: Leader) {
        //TODO
//        if let profileVC = UIStoryboard(name: PROFILE, bundle: nil).instantiateViewController(withIdentifier: PROFILE_VC) as? ProfileVC {
//            profileVC.initData(userId: leader.userId)
//            profileVC.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(profileVC, animated: true)
//        }
        
        let userVC = UserVC(
            user: leader.user,
            delegate: nil
        )
        navigationController?.pushViewController(
            userVC,
            animated: true
        )
    }
}

extension LeaderboardVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        else {
            return leaders.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LEADERBOARD_HEADER_IMAGE_CELL,
                for: indexPath
            ) as! LeaderboardHeaderImageCell
            
            return cell
        }
        else {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LEADER_CELL,
                for: indexPath
            ) as! LeaderCell
            
            let leader = leaders[indexPath.row]
            let leaderRowNumber = indexPath.row + 1
            cell.configureCell(
                leader: leader,
                rowNumber: leaderRowNumber
            )
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return LEADERBOARD_HEADER_IMAGE_CELL_HEIGHT
        }
        else {
            return LEADER_CELL_HEIGHT
        }
    }
}

extension LeaderboardVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let leader = leaders[indexPath.row]
        showLeaderProfile(leader: leader)
    }
}
