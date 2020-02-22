//
//  CompetitionFeedNC.swift
//  Versus
//
//  Created by JT Smrdel on 2/22/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

class CompetitionFeedNC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "Home"),
            tag: 0
        )
        
        let vc = CompetitionFeedContainerVC()
        vc.loadViewIfNeeded()
        addChild(vc)
        
        isNavigationBarHidden = true
    }
}
