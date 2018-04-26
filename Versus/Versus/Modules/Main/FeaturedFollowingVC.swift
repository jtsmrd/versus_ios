//
//  FeaturedFollowingVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class FeaturedFollowingVC: UIViewController {

    
    @IBOutlet weak var featuredTableView: UITableView!
    
    var featuredCompetitions = [Competition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getFeaturedCompetitions()
    }
    
    private func getFeaturedCompetitions() {
        
        CompetitionService.instance.getFeaturedCompetitions { (competitions, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else {
                    self.featuredCompetitions.removeAll()
                    self.featuredCompetitions.append(contentsOf: competitions)
                    self.featuredTableView.reloadData()
                }
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

extension FeaturedFollowingVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return featuredCompetitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: COMPETITION_CELL, for: indexPath) as? CompetitionCell {
            cell.configureCell(competition: featuredCompetitions[indexPath.row])
            return cell
        }
        return CompetitionCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 188
    }
}

extension FeaturedFollowingVC: UITableViewDelegate {
    
}
