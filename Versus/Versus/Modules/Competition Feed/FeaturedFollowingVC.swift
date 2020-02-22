//
//  FeaturedFollowingVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/25/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

class FeaturedFollowingVC: UIViewController {
    
    
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
    
    private let competitionService = CompetitionService.instance
    private let notificationCenter = NotificationCenter.default
    
    private var activeCompetitionFeedType: CompetitionFeedType = .featured
    private var featuredCompetitions = [Competition]()
    private var followedUserCompetitions = [Competition]()
    private let pendingImageOperations = ImageOperations()
    private var featuredRefreshControl: UIRefreshControl!
    private var followedRefreshControl: UIRefreshControl!
    private var selectedIndexPath: IndexPath?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    
    
    
    @IBAction func featuredFollowingSegmentedControlAction(_ sender: UISegmentedControl) {
        
        activeCompetitionFeedType = sender.selectedSegmentIndex == 0 ? .featured : .followedUsers
        
        toggleCompetitionFeedTableView()
    }

    
    
    
    private func toggleCompetitionFeedTableView() {
        
        switch activeCompetitionFeedType {
            
        case .featured:
            followedUserCompetitionsContainerView.isHidden = true
            featuredCompetitionsContainerView.isHidden = false
            featuredTableView.reloadData()
            
        case .followedUsers:
            featuredCompetitionsContainerView.isHidden = true
            followedUserCompetitionsContainerView.isHidden = false
            followedUsersTableView.reloadData()
        }
    }
}
