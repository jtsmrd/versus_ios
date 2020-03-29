//
//  CompetitionFeedContainerVC.swift
//  Versus
//
//  Created by JT Smrdel on 2/22/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

class CompetitionFeedContainerVC: UIViewController {

    enum ScreenPosition {
        case center
        case left
        case right
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var competitionFeedTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var feedContainerView: UIView!
    
    
    // MARK: - Variables
    
    private var activeCompetitionFeedType: CompetitionFeedType = .featured
    private var featuredFeed: CompetitionFeedVC!
    private var followedUserFeed: CompetitionFeedVC!
    
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addCompetitionFeedViewControllers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // todo: Configure this elsewhere. Maybe in the app delegate when a
        // certain amount of time has passed.
        // Request authorization for push notifications here, since it's the
        // first screen the user will see after signing up.
        appDelegate.registerForPushNotifications()
    }
    
    
    // MARK: - Actions
    
    @IBAction func competitionFeedTypeChanged() {
        
        let index = competitionFeedTypeSegmentedControl.selectedSegmentIndex
        
        activeCompetitionFeedType = index == 0 ? .featured : .followedUsers
        
        toggleCompetitionFeed(type: activeCompetitionFeedType)
    }
    
    
    // MARK: - Private Methods
    
    private func addCompetitionFeedViewControllers() {
        
        featuredFeed = CompetitionFeedVC(type: .featured)
        addChild(featuredFeed)
        featuredFeed.view.frame = getFrameFor(position: .center)
        feedContainerView.insertSubview(featuredFeed.view, at: 0)
        featuredFeed.didMove(toParent: self)
        
        followedUserFeed = CompetitionFeedVC(type: .followedUsers)
        addChild(followedUserFeed)
        followedUserFeed.view.frame = getFrameFor(position: .right)
        feedContainerView.insertSubview(followedUserFeed.view, at: 0)
        followedUserFeed.didMove(toParent: self)
    }
    
    
    private func getFrameFor(position: ScreenPosition) -> CGRect {
        
        let screenWidth = UIWindow().bounds.width
        var deltaX: CGFloat = 0.0
        
        switch position {
            
        case .center:
            deltaX = 0.0
            
        case .left:
            deltaX = -(screenWidth)
            
        case .right:
            deltaX = screenWidth
        }
        
        return CGRect(
            x: view.frame.origin.x + deltaX,
            y: view.frame.origin.y,
            width: feedContainerView.frame.width,
            height: feedContainerView.frame.height
        )
    }
    
    
    private func toggleCompetitionFeed(
        type: CompetitionFeedType,
        animated: Bool = true
    ) {
        
        let animationDuration = animated ? 0.25 : 0
        let leftPosition = self.getFrameFor(position: .left)
        let centerPosition = self.getFrameFor(position: .center)
        let rightPosition = self.getFrameFor(position: .right)
        
        switch type {
        case .featured:
            
            UIView.animate(withDuration: animationDuration) {
                
                self.featuredFeed.view.frame = centerPosition
                self.followedUserFeed.view.frame = rightPosition
            }
            
        case .followedUsers:
            
            UIView.animate(withDuration: animationDuration) {
                
                self.followedUserFeed.view.frame = centerPosition
                self.featuredFeed.view.frame = leftPosition
            }
        }
        
        self.featuredFeed.view.layoutIfNeeded()
        self.followedUserFeed.view.layoutIfNeeded()
    }
}
