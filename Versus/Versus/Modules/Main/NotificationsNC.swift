//
//  NotificationsNC.swift
//  Versus
//
//  Created by JT Smrdel on 2/22/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

class NotificationsNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "Notifications"),
            tag: 3
        )
        
        let vc = NotificationsVC()
        vc.loadViewIfNeeded()
        addChild(vc)
        
        isNavigationBarHidden = true
    }
}
