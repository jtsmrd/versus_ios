//
//  CurrentUser.swift
//  Versus
//
//  Created by JT Smrdel on 4/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class CurrentUser {
    
    static var user: AWSUser!
    static var profileImage: UIImage?
    static var profileBackgroundImage: UIImage?
    static var rank: Rank {
        get {
            return RankCollection.instance.ranks.first(where: { $0.id == Int(exactly: user._rankId!)! })!
        }
    }
    static var userPoolUserId: String {
        get {
            return AWSCognitoIdentityUserPool.default().currentUser()?.username ?? ""
        }
    }
    
    private init() { }
}
