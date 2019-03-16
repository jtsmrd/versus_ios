//
//  FollowerSuggestionCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/17/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol FollowerSuggestionCellDelegate {
    func followerSuggestionCellFollowButtonActionError(error: CustomError)
}

class FollowerSuggestionCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    var user: User!
    var followStatus: FollowStatus = .notFollowing
    var delegate: FollowerSuggestionCellDelegate!
    
    
    @IBAction func followButtonAction() {
        switch followStatus {
        case .following:
            displayConfirmUnfollowUser()
        case .notFollowing:
            followUser()
        }
    }
    
    
    func configureCell(user: User, delegate: FollowerSuggestionCellDelegate) {
        self.user = user
        self.delegate = delegate
        
        determineUserFollowStatus()
        configureFollowerButton()
        
        usernameLabel.text = "@\(user.username)"
        displayNameLabel.text = user.name
        
        //TODO
//        if user.profileImage == nil {
//            S3BucketService.instance.downloadImage(
//                mediaId: user.userId,
//                imageType: .small
//            ) { (image, customError) in
//                if let customError = customError {
//                    debugPrint(customError)
//                }
//                else if let image = image {
//                    self.user.profileImage = image
//                    DispatchQueue.main.async {
//                        self.profileImageView.image = image
//                    }
//                }
//            }
//        }
    }
    
    private func determineUserFollowStatus() {
        //TODO
//        followStatus = CurrentUser.getFollowerStatusFor(userId: user.userId)
    }
    
    // Configure button to display 'follow' for unfollowed users or 'following' for followed users
    private func configureFollowerButton() {
        followButton.setButtonState(followStatus: followStatus)
    }
    
    private func followUser() {
        //TODO
//        CurrentUser.follow(
//            user: user
//        ) { (customError) in
//            if let customError = customError {
//                self.delegate.followerSuggestionCellFollowButtonActionError(error: customError)
//                return
//            }
//            self.determineUserFollowStatus()
//            self.configureFollowerButton()
//        }
    }
    
    private func displayConfirmUnfollowUser() {
        if let parentVC = parentViewController {
            let confirmUnfollowAlertVC = UIAlertController(title: "Confirm Unfollow", message: "Are you sure you want to unfollow @\(user.username)", preferredStyle: .actionSheet)
            confirmUnfollowAlertVC.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { (action) in
                self.unfollowUser()
            }))
            confirmUnfollowAlertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            parentVC.present(confirmUnfollowAlertVC, animated: true, completion: nil)
        }
    }
    
    private func unfollowUser() {
        //TODO
//        CurrentUser.unfollow(
//            user: user
//        ) { (customError) in
//            if let customError = customError {
//                self.delegate.followerSuggestionCellFollowButtonActionError(error: customError)
//                return
//            }
//            self.determineUserFollowStatus()
//            self.configureFollowerButton()
//        }
    }
}
