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

        let currentUserVC = CurrentUserVC(user: CurrentAccount.user)
        addChild(currentUserVC)
    }
}
