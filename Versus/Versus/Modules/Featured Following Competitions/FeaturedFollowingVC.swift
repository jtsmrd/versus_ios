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
    
//    private let competitionService = CompetitionService.instance
    private let notificationCenter = NotificationCenter.default
    
    @IBOutlet weak var featuredCompetitionsContainerView: UIView!
    @IBOutlet weak var featuredTableView: UITableView!
    @IBOutlet weak var noFeaturedCompetitionsView: UIView!
    @IBOutlet weak var noFeaturedCompetitionsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noFeaturedCompetitionsReloadButton: UIButton!
    @IBOutlet weak var followedUserCompetitionsContainerView: UIView!
    @IBOutlet weak var followedUsersTableView: UITableView!
    @IBOutlet weak var noFollowedUserCompetitionsView: UIView!
    @IBOutlet weak var noFollowedUserCompetitionsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noFollowedUserCompetitionsReloadButton: UIButton!
    
    var activeCompetitionFeedType: CompetitionFeedType = .featured
    var featuredCompetitions = [Competition]()
    var followedUserCompetitions = [Competition]()
    var featuredRefreshControl: UIRefreshControl!
    var followedRefreshControl: UIRefreshControl!
    var selectedIndexPath: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        featuredTableView.register(UINib(nibName: COMPETITION_CELL, bundle: nil), forCellReuseIdentifier: COMPETITION_CELL)
        followedUsersTableView.register(UINib(nibName: COMPETITION_CELL, bundle: nil), forCellReuseIdentifier: COMPETITION_CELL)
        
        let attributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)]
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
        
        notificationCenter.addObserver(
            self,
            selector: #selector(FeaturedFollowingVC.userVoteUpdated(notification:)),
            name: NSNotification.Name.OnUserVoteUpdated,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check for featured/ followed user competitions when the user switches back to this screen
        // only there are no competitions for the specific competitions feed
        if noFeaturedCompetitionsView.isHidden == false {
            getFeaturedCompetitions()
        }
        
        if noFollowedUserCompetitionsView.isHidden == false {
            getFollowedUserCompetitions()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Request authorization for push notifications here, since it's the first screen the user
        // will see after signing up.
        appDelegate.registerForPushNotifications()
        
        selectedIndexPath = nil
    }
    
    
    /**
     
     */
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    
    /**
     
     */
    @objc func userVoteUpdated(notification: Notification) {
        if let selectedIndexPath = selectedIndexPath {
            DispatchQueue.main.async {
                switch self.activeCompetitionFeedType {
                case .featured:
                    self.featuredTableView.reloadRows(at: [selectedIndexPath], with: .automatic)
                case .following:
                    self.followedUsersTableView.reloadRows(at: [selectedIndexPath], with: .automatic)
                }
            }
        }
    }
    
    
    @IBAction func featuredFollowingSegmentedControlAction(_ sender: UISegmentedControl) {
        activeCompetitionFeedType = sender.selectedSegmentIndex == 0 ? .featured : .following
        
        toggleCompetitionFeedTableView()
    }
    
    
    @IBAction func noFeaturedCompetitionsReloadButtonAction() {
        noFeaturedCompetitionsReloadButton.isEnabled = false
        noFeaturedCompetitionsActivityIndicator.startAnimating()
        getFeaturedCompetitions()
    }
    
    
    @IBAction func noFollowedUserCompetitionsReloadButtonAction() {
        noFollowedUserCompetitionsReloadButton.isEnabled = false
        noFollowedUserCompetitionsActivityIndicator.startAnimating()
        getFollowedUserCompetitions()
    }
    
    
    @objc func getFeaturedCompetitions() {
        //TODO
//        CompetitionManager.instance.getFeaturedCompetitions { (competitions, customError) in
//            DispatchQueue.main.async {
//                if let customError = customError {
//                    debugPrint(customError.message)
//                }
//                else {
//                    self.featuredCompetitions = competitions
//                    self.featuredTableView.reloadData()
//                }
//                self.noFeaturedCompetitionsReloadButton.isEnabled = true
//                self.noFeaturedCompetitionsActivityIndicator.stopAnimating()
//                self.featuredTableView.refreshControl?.endRefreshing()
//            }
//        }
    }
    
    @objc func getFollowedUserCompetitions() {
        
        //TODO
//        CurrentUser.getFollowedUsers { (followedUsers, customError) in
//            DispatchQueue.main.async {
//                if let customError = customError {
//                    debugPrint(customError.message)
//                    self.noFollowedUserCompetitionsReloadButton.isEnabled = true
//                    self.noFollowedUserCompetitionsActivityIndicator.stopAnimating()
//                }
//                else if !followedUsers.isEmpty {
//                    let followedUserIds = followedUsers.map({ $0.followedUserUserId })
//
//                    self.competitionService.getFollowedUserCompetitions(
//                        followedUserIds: followedUserIds
//                    ) { (competitions, customError) in
//                        DispatchQueue.main.async {
//                            if let customError = customError {
//                                debugPrint(customError.message)
//                            }
//                            else {
//                                self.followedUserCompetitions = competitions
//                                self.followedUsersTableView.reloadData()
//                                self.followedUsersTableView.refreshControl?.endRefreshing()
//                            }
//                            self.noFollowedUserCompetitionsReloadButton.isEnabled = true
//                            self.noFollowedUserCompetitionsActivityIndicator.stopAnimating()
//                        }
//                    }
//                }
//                else {
//                    self.noFollowedUserCompetitionsReloadButton.isEnabled = true
//                    self.noFollowedUserCompetitionsActivityIndicator.stopAnimating()
//                    self.followedUsersTableView.refreshControl?.endRefreshing()
//                }
//            }
//        }
    }

    
    private func toggleCompetitionFeedTableView() {
        switch activeCompetitionFeedType {
        case .featured:
            followedUserCompetitionsContainerView.isHidden = true
            featuredCompetitionsContainerView.isHidden = false
            featuredTableView.reloadData()
        case .following:
            featuredCompetitionsContainerView.isHidden = true
            followedUserCompetitionsContainerView.isHidden = false
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
            let featuredCompetitionsCount = featuredCompetitions.count
            DispatchQueue.main.async {
                self.noFeaturedCompetitionsView.isHidden = featuredCompetitionsCount > 0 ? true : false
            }
            return featuredCompetitionsCount
        case .following:
            let followedUserCompetitionsCount = followedUserCompetitions.count
            DispatchQueue.main.async {
                self.noFollowedUserCompetitionsView.isHidden = followedUserCompetitionsCount > 0 ? true : false
            }
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
        
        selectedIndexPath = indexPath
        switch activeCompetitionFeedType {
        case .featured:
            showCompetition(competition: featuredCompetitions[indexPath.row])
        case .following:
            showCompetition(competition: followedUserCompetitions[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
