//
//  CurrentUserNC.swift
//  Versus
//
//  Created by JT Smrdel on 3/16/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import UIKit

class CurrentUserNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "Profile"),
            tag: 4
        )
        
        let vc = CurrentUserVC(
            user: CurrentAccount.user
        )
        vc.loadViewIfNeeded()
        addChild(vc)
        
        isNavigationBarHidden = true
    }
}
