//
//  NotificationCell.swift
//  Versus
//
//  Created by JT Smrdel on 5/16/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var notificationImageView: CircleImageView!
    @IBOutlet weak var notificationTextLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var competitionImageView: UIImageView!
    
    var followStatus: FollowStatus = .notFollowing
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(notification: Notification) {
        
        // The default notification image, will be overwritten in some cases
        notificationImageView.image = UIImage(named: "versus_icon_white")
        
        switch notification.notificationType {
        case .competitionComment, .competitionLost, .competitionRemoved, .competitionStarted, .competitionWon:
            
            competitionImageView.isHidden = false
            followButton.isHidden = true
            rankImageView.isHidden = true
            
            let notificationInfo = notification.notificationInfo as! CompetitionNotificationInfo
            
            // Set the notification image view image to the commenting users' profile image
            if let userPoolUserId = notificationInfo.userPoolUserId, notification.notificationType == .competitionComment {
                UserService.instance.downloadImage(
                    userPoolUserId: userPoolUserId,
                    bucketType: .profileImageSmall
                ) { (image) in
                    DispatchQueue.main.async {
                        self.notificationImageView.image = image
                    }
                }
            }
            
            // competition image view = competition image for current user
            CompetitionService.instance.getCompetition(with: notificationInfo.competitionId) { (competition, customError) in
                DispatchQueue.main.async {
                    if let customError = customError {
                        self.parentViewController?.displayError(error: customError)
                    }
                    else if let competition = competition {
                        
                        // We want to display the competition image for the current user,
                        // so just check if the CurrentUser userPoolUserId matches user1 or user 2.
                        let competitionUser: CompetitionUser = competition.awsCompetition._user1userPoolUserId! == CurrentUser.userPoolUserId ? .user1 : .user2
                        
                        var bucketType: S3BucketType!
                        
                        switch competition.competitionType {
                        case .image:
                            bucketType = .competitionImageSmall
                        case .video:
                            bucketType = .competitionVideoPreviewImageSmall
                        }
                        
                        competition.getCompetitionImage(
                            for: competitionUser,
                            bucketType: bucketType,
                            completion: { (image, error) in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        self.parentViewController?.displayError(error: error)
                                    }
                                    else {
                                        self.competitionImageView.image = image
                                    }
                                }
                            }
                        )
                    }
                }
            }
            
            if let username = notificationInfo.username {
                notificationTextLabel.text = notificationInfo.notificationText.replacingOccurrences(of: "#username", with: "@" + username)
            }
            else {
                notificationTextLabel.text = notificationInfo.notificationText
            }
            
        case .follower:
            
            followButton.isHidden = false
            competitionImageView.isHidden = true
            rankImageView.isHidden = true
            
            let notificationInfo = notification.notificationInfo as! FollowerNotificationInfo
            
            determineUserFollowStatus(userPoolUserId: notificationInfo.followerUserPoolUserId)
            configureFollowerButton()
            
            // Set the notification image view image to the following users' profile image
            UserService.instance.downloadImage(
                userPoolUserId: notificationInfo.followerUserPoolUserId,
                bucketType: .profileImageSmall
            ) { (image) in
                DispatchQueue.main.async {
                    self.notificationImageView.image = image
                }
            }
            
            notificationTextLabel.text = notificationInfo.notificationText.replacingOccurrences(of: "#username", with: "@" + notificationInfo.followerUsername)
            
        case .rankUp:
            
            rankImageView.isHidden = false
            followButton.isHidden = true
            competitionImageView.isHidden = true
            
            let notificationInfo = notification.notificationInfo as! RankUpNotificationInfo
            
            notificationTextLabel.text = notificationInfo.notificationText
            rankImageView.image = RankCollection.instance.rankIconFor(rankId: notificationInfo.newRankId)
        }
    }
    
    @IBAction func followButtonAction() {
        
    }
    
    private func determineUserFollowStatus(userPoolUserId: String) {
        followStatus = CurrentUser.followStatus(for: userPoolUserId)
    }
    
    // Configure button to display 'follow' for unfollowed users or 'following' for followed users
    private func configureFollowerButton() {
        followButton.setButtonState(followStatus: followStatus)
    }
}
