//
//  DiscoverNC.swift
//  Versus
//
//  Created by JT Smrdel on 2/22/20.
//  Copyright © 2020 VersusTeam. All rights reserved.
//

import UIKit

class DiscoverNC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "Search"),
            tag: 1
        )
        
//        let searchStoryboard = UIStoryboard(
//            name: "Search",
//            bundle: nil
//        )
//        let vc = searchStoryboard.instantiateViewController(
//            withIdentifier: "SearchBrowseVC"
//            ) as! SearchBrowseVC
        let vc = DiscoverVC()
        vc.loadViewIfNeeded()
        addChild(vc)
        
        isNavigationBarHidden = true
    }
}
