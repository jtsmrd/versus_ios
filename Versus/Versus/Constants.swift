//
//  Constants.swift
//  Versus
//
//  Created by JT Smrdel on 3/31/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider

// AWS

let CognitoIdentityUserPoolRegion: AWSRegionType = .USEast1
let CognitoIdentityUserPoolId = "us-east-1:884a7e32-302b-4c41-a955-ebb3ac3a0c87"
let CognitoIdentityUserPoolAppClientId = "5bblc6bpht6itt8gss3kagokiv"
let CognitoIdentityUserPoolAppClientSecret = "hg15srh5vkleu1euchc06ium381gp08vm7resjcee00thlafbqn"
let AWSCognitoUserPoolsSignInProviderKey = "UserPool"


// Segues

let SHOW_LOGIN = "LoginVC"
let SHOW_SIGNUP = "SignupVC"
let SHOW_VERIFY_ACCOUNT = "VerifyUserVC"
let SHOW_CHOOSE_USERNAME = "ChooseUsernameVC"
let SHOW_FOLLOW_SUGGESTIONS = "FollowSuggestionsVC"
let SHOW_MAIN_STORYBOARD = "ShowMainStoryboard"

let UNWIND_TO_LANDING = "LandingVC"


// Completions

typealias SuccessCompletion = (Bool) -> ()
