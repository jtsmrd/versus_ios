//
//  FollowerCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol FollowerCellDelegate {
    func followerCellFollowButtonActionError(error: CustomError)
    func followerCellFollowButtonActionUnfollow(follower: Follower)
}

class FollowerCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    weak var follower: Follower?
    var delegate: FollowerCellDelegate?
    
    //TODO
//    var followStatus: FollowStatus {
//        return CurrentUser.getFollowedUserStatusFor(userId: follower!.followerUserId)
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = nil
        usernameLabel.text = nil
        displayNameLabel.text = nil
        follower = nil
        delegate = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    /**
     
     */
    @IBAction func followButtonAction() {
        //TODO
//        CurrentUser.follow(
//            follower: follower!
//        ) { (customError) in
//            DispatchQueue.main.async {
//                if let customError = customError {
//                    self.delegate?.followerCellFollowButtonActionError(error: customError)
//                    return
//                }
//                self.followButton.setButtonState(followStatus: self.followStatus)
//            }
//        }
    }
    
    
    /**
     
     */
    func configureCell(follower: Follower, delegate: FollowerCellDelegate) {
        //TODO
//        self.follower = follower
//        self.delegate = delegate
//        followButton.isHidden = CurrentUser.userIsMe(userId: follower.followerUserId)
//        followButton.setButtonState(followStatus: followStatus)
//        usernameLabel.text = follower.username
//        displayNameLabel.text = follower.displayName
//
//        // TODO: Remove from cell class and use operation queue.
//        S3BucketService.instance.downloadImage(mediaId: follower.followerUserId, imageType: .small) { (image, customError) in
//
//            DispatchQueue.main.async {
//                self.profileImageView.image = image
//            }
//        }
    }
}
