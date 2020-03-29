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
    
    
    private let competitionService = CompetitionService.instance
    private let s3BucketService = S3BucketService.instance
    
    
    private var notification: Notification?
    private var followStatus: FollowStatus = .notFollowing
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        notificationImageView.image = nil
        notificationTextLabel.text = nil
        rankImageView.image = nil
        competitionImageView.image = nil
        notification = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func followButtonAction() {
            
    }
        
    
    
    private func determineUserFollowStatus(userId: Int) {
        CurrentAccount.getFollowStatusFor(userId: userId)
    }
        
    
    // Configure button to display 'follow' for unfollowed users or 'following' for followed users
    private func configureFollowerButton() {
        followButton.setButtonState(followStatus: followStatus)
    }
    
    
    private func configureForCompetitionNotification(notification: Notification) {
        
        competitionImageView.isHidden = false
        followButton.isHidden = true
        rankImageView.isHidden = true
        
        let notificationInfo = notification.notificationPayload as! CompetitionNotificationInfo

        // Set the notification image view image to the commenting users' profile image
//        if notification.type.typeEnum == .newComment {
//
//            DispatchQueue.global(qos: .userInitiated).async {
//
//                self.s3BucketService.downloadImage(
//                    mediaId: notification.userId,
//                    imageType: .small
//                ) { [weak self] (image, errorMessage) in
//
//                    if let errorMessage = errorMessage {
//
//                        self?.parentViewController?.displayMessage(
//                            message: errorMessage
//                        )
//                        return
//                    }
//                    self?.notificationImageView.image = image
//                }
//            }
//        }
        
//        competitionService.getCompetition(
//            competitionId: notificationInfo.competitionId
//        ) { [weak self] (competition, error) in
//            guard let self = self else { return }
//
//            if let error = error {
//                DispatchQueue.main.async {
//                    self.parentViewController?.displayMessage(message: error)
//                }
//            }
//            else if let competition = competition {
//
//                // Get and display the competition image for the current user
//                var mediaId = ""
//                if CurrentAccount.userIsMe(userId: competition.leftEntry.user.id) {
//                    mediaId = competition.leftEntry.mediaId
//                }
//                else {
//                    mediaId = competition.rightEntry.mediaId
//                }
//
//                self.s3BucketService.downloadImage(
//                    mediaId: mediaId,
//                    imageType: .regular
//                ) { [weak self] (image, error) in
//                    guard let self = self else { return }
//
//                    DispatchQueue.main.async {
//                        self.competitionImageView.image = image
//                    }
//                }
//            }
//        }
    }
    
    
    private func configureForFollowerNotification(notification: Notification) {
        
        followButton.isHidden = false
        competitionImageView.isHidden = true
        rankImageView.isHidden = true

        let notificationInfo = notification.notificationPayload as! FollowerNotificationInfo

        determineUserFollowStatus(
            userId: notificationInfo.followerUserId
        )
        configureFollowerButton()
    }
    
    
    private func configureForRankUpNotification(notification: Notification) {
        
        rankImageView.isHidden = false
        followButton.isHidden = true
        competitionImageView.isHidden = true

        let notificationInfo = notification.notificationPayload as! RankUpNotificationInfo

        let newRank = Rank(rankId: notificationInfo.newRankId)
        rankImageView.image = newRank.image
    }
    

    
    func configureCell(notification: Notification) {
        self.notification = notification
        
        if let image = notification.image {
            notificationImageView.image = image
        }
        else {
            notificationImageView.image = UIImage(
                named: "versus_icon_white"
            )
        }
        
        notificationTextLabel.text = notification.message
        
        // New notifications will have a background color. Once viewed, it will be clear.
        backgroundColor = notification.wasViewed ? UIColor.white : #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 0.05)
        
        switch notification.type.typeEnum {
            
        case .competitionWon, .competitionLost, .competitionMatched,
             .newFollowedUserCompetition, .newVote, .newComment:
            configureForCompetitionNotification(notification: notification)
            
        case .newFollower:
            configureForFollowerNotification(notification: notification)
            
        case .rankUp:
            configureForRankUpNotification(notification: notification)
            
        case .leaderboard, .topLeader:
            return
            
        case .newDirectMessage:
            return
        }
    }
    
    func updateImage() {
        
        if let image = notification?.image {
            notificationImageView.image = image
        }
    }
}
