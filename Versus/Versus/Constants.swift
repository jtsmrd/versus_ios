//
//  Constants.swift
//  Versus
//
//  Created by JT Smrdel on 3/31/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

// AWS User Pool and Identity

//let CognitoIdentityUserPoolRegion: AWSRegionType = .USEast1
let CognitoIdentityUserPoolId = "us-east-1:884a7e32-302b-4c41-a955-ebb3ac3a0c87"
let CognitoIdentityUserPoolAppClientId = "5bblc6bpht6itt8gss3kagokiv"
let CognitoIdentityUserPoolAppClientSecret = "hg15srh5vkleu1euchc06ium381gp08vm7resjcee00thlafbqn"
let AWSCognitoUserPoolsSignInProviderKey = "UserPool"


// AWS S3 Bucket

let S3_BUCKET = "versus-userfiles-mobilehub-387870640"
let IMAGE_BUCKET = "public/image/"
let VIDEO_BUCKET = "public/video/"


// Segues

let SHOW_LOGIN = "LoginVC"
let SHOW_SIGNUP = "SignupVC"
let SHOW_FOLLOW_SUGGESTIONS = "FollowSuggestionsVC"
let SHOW_MAIN_STORYBOARD = "ShowMainStoryboard"
let SHOW_RANKS = "RankVC"
let SHOW_PROFILE = "ProfileVC"
let SHOW_FOLLOWERS = "FollowerVC"
let SHOW_FOLLOWED_USERS = "FollowedUserVC"
let SHOW_COMPETITION_DETAILS = "CompetitionDetailsVC"
let SHOW_COMPETITION_SUBMITTED = "CompetitionSubmittedVC"
let SHOW_COMPETITION = "ViewCompetitionVC"
let SHOW_SELECT_PREVIEW_IMAGE = "SelectPreviewImageVC"
let FIRST_COMPETITOR = "FirstCompetitorVC"
let SECOND_COMPETITOR = "SecondCompetitorVC"
let SHOW_SELECT_COMPETITION_MEDIA = "SelectCompetitionMediaVC"
let SHOW_UNMATCHED_ENTRIES = "UnmatchedEntriesVC"

let UNWIND_TO_LANDING = "LandingVC"


// Completions

typealias SuccessCompletion = (Bool) -> ()
typealias SuccessErrorCompletion = (_ success: Bool, _ error: CustomError?) -> Void


// TableViewCell Identifiers

let FOLLOWER_CELL = "FollowerCell"
let FOLLOWED_USER_CELL = "FollowedUserCell"
let SEARCH_USER_CELL = "SearchUserCell"
let NEW_SEARCH_INFO_CELL = "NewSearchInfoCell"
let NO_USER_SEARCH_RESULTS_CELL = "NoUserSearchResultsCell"
let CATEGORY_CELL = "CategoryCell"
let COMPETITION_CELL = "CompetitionCell"
let NOTIFICATION_CELL = "NotificationCell"
let COMPETITION_COMMENT_CELL = "CompetitionCommentCell"
let ENTRY_CELL = "EntryCell"
let LEADERBOARD_HEADER_IMAGE_CELL = "LeaderboardHeaderImageCell"
let LEADER_CELL = "LeaderCell"


// CollectionViewCell Identifiers

let FOLLOWER_SUGGESTION_CELL = "FollowerSuggestionCell"
let PHOTO_LIBRARY_CELL = "PhotoLibraryCell"
let PROFILE_COMPETITION_CELL = "ProfileCompetitionCell"
let COMPETITION_SHARE_CELL = "CompetitionShareCell"
let COMPETITION_OPTION_CELL = "CompetitionOptionCell"
let LEADERBOARD_CELL = "LeaderboardCell"
let DISCOVER_CATEGORY_CELL = "DiscoverCategoryCell"


// CollectionViewHeader Identifiers

let PROFILE_INFO_COLLECTION_VIEW_HEADER = "ProfileInfoCollectionViewHeader"


// Storyboard Identifiers

let CHOOSE_USERNAME_VC = "ChooseUsernameVC"
let SELECT_COMPETITION_MEDIA_VC = "SelectCompetitionMediaVC"
let VIEW_COMPETITION_VC = "ViewCompetitionVC"
let PROFILE_VC = "ProfileVC"
let EDIT_PROFILE_VC = "EditProfileVC"
let CHANGE_PASSWORD_VC = "ChangePasswordVC"


// Storyboards

let MAIN = "Main"
let LOGIN = "Login"
let PROFILE = "Profile"
let ENTRY = "Entry"
let COMPETITION = "Competition"
let NOTIFICATIONS = "Notifications"
let EDIT_IMAGE = "EditImage"
