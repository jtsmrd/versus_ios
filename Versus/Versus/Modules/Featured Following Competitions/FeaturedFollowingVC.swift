//
//  FeaturedFollowingVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class FeaturedFollowingVC: UIViewController {

    enum CompetitionFeedType {
        case featured
        case following
    }
    
    @IBOutlet weak var featuredTableView: UITableView!
    @IBOutlet weak var followedUsersTableView: UITableView!
    
    var activeCompetitionFeedType: CompetitionFeedType = .featured
    var featuredCompetitions = [Competition]()
    var followedUserCompetitions = [Competition]()
    var featuredRefreshControl: UIRefreshControl!
    var followedRefreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        featuredTableView.register(UINib(nibName: COMPETITION_CELL, bundle: nil), forCellReuseIdentifier: COMPETITION_CELL)
        followedUsersTableView.register(UINib(nibName: COMPETITION_CELL, bundle: nil), forCellReuseIdentifier: COMPETITION_CELL)
        
        let attributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)]
        let refreshTitle = NSAttributedString(string: "Loading Competitions", attributes: attributes)
        
        featuredRefreshControl = UIRefreshControl()
        featuredRefreshControl.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        featuredRefreshControl.attributedTitle = refreshTitle
        featuredRefreshControl.addTarget(self, action: #selector(FeaturedFollowingVC.getFeaturedCompetitions), for: .valueChanged)
        featuredTableView.refreshControl = featuredRefreshControl
        
        followedRefreshControl = UIRefreshControl()
        followedRefreshControl.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        followedRefreshControl.attributedTitle = refreshTitle
        followedRefreshControl.addTarget(self, action: #selector(FeaturedFollowingVC.getFollowedUserCompetitions), for: .valueChanged)
        followedUsersTableView.refreshControl = followedRefreshControl
        
        featuredRefreshControl.beginRefreshing()
        getFeaturedCompetitions()
        
        followedRefreshControl.beginRefreshing()
        getFollowedUserCompetitions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    @IBAction func featuredFollowingSegmentedControlAction(_ sender: UISegmentedControl) {
        activeCompetitionFeedType = sender.selectedSegmentIndex == 0 ? .featured : .following
        
        toggleCompetitionFeedTableView()
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
    
    @objc func getFollowedUserCompetitions() {
        
        CurrentUser.user.getFollowedUsers { (followedUsers, customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.displayError(error: customError)
                }
                else if let followedUsers = followedUsers, followedUsers.count > 0 {
                    let followedUserIds = followedUsers.map({ $0.awsFollower._followedUserId! })
                    
                    CompetitionService.instance.getFollowedUserCompetitions(followedUserIds) { (competitions, customError) in
                        DispatchQueue.main.async {
                            if let error = customError {
                                self.displayError(error: error)
                            }
                            else {
                                self.followedUserCompetitions = competitions
                                self.followedUsersTableView.reloadData()
                                self.followedUsersTableView.refreshControl?.endRefreshing()
                            }
                        }
                    }
                }
                else {
                    self.followedUsersTableView.refreshControl?.endRefreshing()
                }
            }
        }
    }

    
    private func toggleCompetitionFeedTableView() {
        switch activeCompetitionFeedType {
        case .featured:
            followedUsersTableView.isHidden = true
            featuredTableView.isHidden = false
            featuredTableView.reloadData()
        case .following:
            featuredTableView.isHidden = true
            followedUsersTableView.isHidden = false
            followedUsersTableView.reloadData()
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
        switch activeCompetitionFeedType {
        case .featured:
            return featuredCompetitions.count
        case .following:
            return followedUserCompetitions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: COMPETITION_CELL, for: indexPath) as? CompetitionCell {
            switch activeCompetitionFeedType {
            case .featured:
                cell.configureCell(competition: featuredCompetitions[indexPath.row])
            case .following:
                cell.configureCell(competition: followedUserCompetitions[indexPath.row])
            }
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
        
        switch activeCompetitionFeedType {
        case .featured:
            showCompetition(competition: featuredCompetitions[indexPath.row])
        case .following:
            showCompetition(competition: followedUserCompetitions[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
