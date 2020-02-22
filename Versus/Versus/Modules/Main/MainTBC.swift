//
//  MainTBC.swift
//  Versus
//
//  Created by JT Smrdel on 4/17/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class MainTBC: UITabBarController {
    
    private var competitionFeedNC: CompetitionFeedNC!
    private var discoverNC: DiscoverNC!
    private var entryPlaceholderVC: UIViewController!
    private var notificationsNC: NotificationsNC!
    private var currentUserNC: CurrentUserNC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        configureTabs()
        
        addEntryButton()
    }

    
    @objc func newEntryButtonAction() {
        
        let entryNC = EntryNC()
        entryNC.loadViewIfNeeded()
        
        present(entryNC, animated: true, completion: nil)
    }
    
    
    private func configureTabs() {
        
        competitionFeedNC = CompetitionFeedNC()
        competitionFeedNC.loadViewIfNeeded()
        
        discoverNC = DiscoverNC()
        discoverNC.loadViewIfNeeded()
        
        entryPlaceholderVC = UIViewController()
        
        notificationsNC = NotificationsNC()
        notificationsNC.loadViewIfNeeded()
        
        currentUserNC = CurrentUserNC()
        currentUserNC.loadViewIfNeeded()
        
        setViewControllers(
            [
                competitionFeedNC,
                discoverNC,
                entryPlaceholderVC,
                notificationsNC,
                currentUserNC
            ],
            animated: false
        )
    }
    
    
    private func addEntryButton() {
        
        let tabBarHeight = tabBar.frame.size.height
        
        let circleView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tabBarHeight * 0.95, height: tabBarHeight * 0.95))
        circleView.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 0.5)
        circleView.layer.cornerRadius = circleView.frame.height / 2
        circleView.clipsToBounds = true
        circleView.center = CGPoint(x: tabBar.center.x, y: (circleView.frame.height / 2) * 1.05)
        
        let circleViewHeight = circleView.frame.size.height
        
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: circleViewHeight, height: circleViewHeight))
        button.setImage(UIImage(named: "temp_icon_red"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.center = CGPoint(x: circleViewHeight / 2, y: circleViewHeight / 2)
        button.addTarget(self, action: #selector(newEntryButtonAction), for: .touchUpInside)
        
        circleView.addSubview(button)
        tabBar.addSubview(circleView)
    }
}

extension MainTBC: UITabBarControllerDelegate {
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        // The profile tab was selected.
//        if let navController = viewController as? UINavigationController, let profileVC = navController.children.first as? ProfileVC {
//
//            // Configure the ProfileVC for the current user.
//            profileVC.initData(userId: CurrentAccount.user.id)
//        }
    }
}
