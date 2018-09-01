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
    
    
    var leaderboard: Leaderboard!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLeaders()
    }

    
    func initData(leaderboard: Leaderboard) {
        self.leaderboard = leaderboard
    }
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    private func getLeaders() {
        
        leaderboard.getLeaders { (success, customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.displayError(error: customError)
                }
                else if success {
                    self.leadersTableView.reloadData()
                }
            }
        }
    }
    
    
    private func showLeaderProfile(leader: Leader) {
        if let profileVC = UIStoryboard(name: PROFILE, bundle: nil).instantiateViewController(withIdentifier: PROFILE_VC) as? ProfileVC {
            profileVC.initData(userId: leader.userId)
            profileVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
        return leaderboard.leaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardHeaderImageCell", for: indexPath) as? LeaderboardHeaderImageCell {
                
                return cell
            }
            return UITableViewCell()
        }
        else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderCell", for: indexPath) as? LeaderCell {
                let leader = leaderboard.leaders[indexPath.row]
                let leaderRank = indexPath.row + 1
                cell.configureCell(leader: leader, leaderboardType: leaderboard.leaderboardType, leaderRank: leaderRank)
                return cell
            }
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }
        return 70
    }
}

extension LeaderboardVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        showLeaderProfile(leader: leaderboard.leaders[indexPath.row])
    }
}
