//
//  Constants.swift
//  Versus
//
//  Created by JT Smrdel on 3/31/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider

// AWS User Pool and Identity

let CognitoIdentityUserPoolRegion: AWSRegionType = .USEast1
let CognitoIdentityUserPoolId = "us-east-1:884a7e32-302b-4c41-a955-ebb3ac3a0c87"
let CognitoIdentityUserPoolAppClientId = "5bblc6bpht6itt8gss3kagokiv"
let CognitoIdentityUserPoolAppClientSecret = "hg15srh5vkleu1euchc06ium381gp08vm7resjcee00thlafbqn"
let AWSCognitoUserPoolsSignInProviderKey = "UserPool"


// AWS S3 Bucket

let S3_BUCKET = "versus-userfiles-mobilehub-387870640"
let PROFILE_IMAGE_BUCKET_PATH = "public/profileImage/"
let PROFILE_IMAGE_SMALL_BUCKET_PATH = "public/profileImageSmall/"
let PROFILE_BACKGROUND_IMAGE_BUCKET_PATH = "public/profileBackgroundImage/"


// Segues

let SHOW_LOGIN = "LoginVC"
let SHOW_SIGNUP = "SignupVC"
let SHOW_VERIFY_USER = "VerifyUserVC"
let SHOW_CHOOSE_USERNAME = "ChooseUsernameVC"
let SHOW_FOLLOW_SUGGESTIONS = "FollowSuggestionsVC"
let SHOW_MAIN_STORYBOARD = "ShowMainStoryboard"
let SHOW_RANKS = "RankVC"
let SHOW_PROFILE = "ProfileVC"

let UNWIND_TO_LANDING = "LandingVC"


// Completions

typealias SuccessCompletion = (Bool) -> ()
