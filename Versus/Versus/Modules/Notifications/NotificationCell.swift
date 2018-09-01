//
//  NotificationCell.swift
//  Versus
//
//  Created by JT Smrdel on 5/16/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    private let competitionService = CompetitionService.instance
    private let s3BucketService = S3BucketService.instance
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        notificationImageView.image = nil
        notificationTextLabel.text = nil
        rankImageView.image = nil
        competitionImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    /**
 
     */
    func configureCell(notification: VersusNotification) {
        
        // The default notification image, will be overwritten in some cases
        notificationImageView.image = UIImage(named: "versus_icon_white")
        
        // New notifications will have a background color. Once viewed, it will be clear.
        backgroundColor = notification.wasViewed ? UIColor.white : #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 0.05)
        
        switch notification.notificationType {
        case .competitionComment, .competitionLost, .competitionRemoved, .competitionStarted, .competitionWon:
            
            competitionImageView.isHidden = false
            followButton.isHidden = true
            rankImageView.isHidden = true
            
            let notificationInfo = notification.notificationInfo as! CompetitionNotificationInfo
            if !notificationInfo.username.isEmpty {
                notificationTextLabel.text = notificationInfo.notificationText.replacingOccurrences(of: "#username", with: "@" + notificationInfo.username)
            }
            else {
                notificationTextLabel.text = notificationInfo.notificationText
            }
            
            // Set the notification image view image to the commenting users' profile image
            if notification.notificationType == .competitionComment {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.s3BucketService.downloadImage(
                        mediaId: notification.userId,
                        imageType: .small
                    ) { [weak self] (image, customError) in
                        if let customError = customError {
                            self?.parentViewController?.displayError(error: customError)
                        }
                        self?.notificationImageView.image = image
                    }
                }
            }
            
            // competition image view = competition image for current user
            DispatchQueue.global(qos: .userInitiated).async {
                self.competitionService.getCompetition(
                    competitionId: notificationInfo.competitionId
                ) { [weak self] (competition, customError) in
                    if let customError = customError {
                        DispatchQueue.main.async {
                            self?.parentViewController?.displayError(error: customError)
                        }
                    }
                    else if let competition = competition {
                        
                        // Get and display the competition image for the current user
                        var currentUserCompetitorRecord: Competitor!
                        if competition.firstCompetitor.userId == CurrentUser.userId {
                            currentUserCompetitorRecord = competition.firstCompetitor
                        }
                        else {
                            currentUserCompetitorRecord = competition.secondCompetitor
                        }
                        currentUserCompetitorRecord.getCompetitionImageSmall(
                            completion: { [weak self] (image, customError) in
                                DispatchQueue.main.async {
                                    if let customError = customError {
                                        self?.parentViewController?.displayError(error: customError)
                                    }
                                    self?.competitionImageView.image = image
                                }
                            }
                        )
                    }
                }
            }
            
        case .follower:
            
            followButton.isHidden = false
            competitionImageView.isHidden = true
            rankImageView.isHidden = true
            
            let notificationInfo = notification.notificationInfo as! FollowerNotificationInfo
            notificationTextLabel.text = notificationInfo.notificationText.replacingOccurrences(of: "#username", with: "@" + notificationInfo.username)
            
            determineUserFollowStatus(userId: notificationInfo.userId)
            configureFollowerButton()
            
            // Set the notification image view image to the following users' profile image
            DispatchQueue.global(qos: .userInitiated).async {
                self.s3BucketService.downloadImage(
                    mediaId: notification.userId,
                    imageType: .small
                ) { [weak self] (image, customError) in
                    DispatchQueue.main.async {
                        if let customError = customError {
                            self?.parentViewController?.displayError(error: customError)
                        }
                        if let image = image {
                            self?.notificationImageView.image = image
                        }
                    }
                }
            }
            
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
    
    private func determineUserFollowStatus(userId: String) {
        followStatus = CurrentUser.getFollowedUserStatusFor(userId: userId)
    }
    
    // Configure button to display 'follow' for unfollowed users or 'following' for followed users
    private func configureFollowerButton() {
        followButton.setButtonState(followStatus: followStatus)
    }
}
