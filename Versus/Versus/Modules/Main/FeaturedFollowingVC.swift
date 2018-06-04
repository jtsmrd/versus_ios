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

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        let attributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)]
        let refreshTitle = NSAttributedString(string: "Loading Competitions", attributes: attributes)
        refreshControl.attributedTitle = refreshTitle
        refreshControl.addTarget(self, action: #selector(FeaturedFollowingVC.getFeaturedCompetitions), for: .valueChanged)
        featuredTableView.refreshControl = refreshControl
        
        refreshControl.beginRefreshing()
        getFeaturedCompetitions()
    }
    
    @objc func getFeaturedCompetitions() {
        
        CompetitionManager.instance.getFeaturedCompetitions { (competitions, customError) in
            DispatchQueue.main.async {
                if let error = customError {
                    self.displayError(error: error)
                }
                else {
                    self.featuredCompetitions = competitions
                    self.featuredTableView.reloadData()
                    self.featuredTableView.refreshControl?.endRefreshing()
                }
            }
        }
    }

    private func showCompetition(competition: Competition) {
        
        if let viewCompetitionVC = UIStoryboard(name: COMPETITION, bundle: nil).instantiateInitialViewController() as? ViewCompetitionVC {
            viewCompetitionVC.initData(competition: competition)
            navigationController?.pushViewController(viewCompetitionVC, animated: true)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCompetition(competition: featuredCompetitions[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
