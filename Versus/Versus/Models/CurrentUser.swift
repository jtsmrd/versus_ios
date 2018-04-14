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
    
    static var user: User!
    static var userPoolUserId: String {
        get {
            return AWSCognitoIdentityUserPool.default().currentUser()?.username ?? ""
        }
    }
    
    private init() { }
}
