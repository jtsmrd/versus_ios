//
//  SearchUserCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/11/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol SearchUserCellDelegate {
    func searchUserCellFollowButtonActionError(error: CustomError)
}

class SearchUserCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    weak var user: User?
    var delegate: SearchUserCellDelegate?
    var followStatus: FollowStatus {
        return CurrentUser.getFollowedUserStatusFor(userId: user!.userId)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = nil
        usernameLabel.text = nil
        displayNameLabel.text = nil
        user = nil
        delegate = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    /**
     
     */
    @IBAction func followButtonAction() {
        switch followStatus {
        case .following:
            displayUnfollowConfirmation()
        case .notFollowing:
            followUser()
        }
    }
    
    
    /**
     
     */
    func configureCell(user: User?, delegate: SearchUserCellDelegate) {
        guard let user = user else {
            // Show loading state
            return
        }
        self.user = user
        self.delegate = delegate
        followButton.setButtonState(followStatus: followStatus)
        usernameLabel.text = user.username
        displayNameLabel.text = user.displayName
        user.getProfileImage { (image, error) in
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
        }
    }
    
    
    /**
 
     */
    private func followUser() {
        CurrentUser.follow(
            user: user!
        ) { (customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.delegate?.searchUserCellFollowButtonActionError(error: customError)
                    return
                }
                self.followButton.setButtonState(followStatus: self.followStatus)
            }
        }
    }
    
    
    /**
     
     */
    private func displayUnfollowConfirmation() {
        if let parentVC = parentViewController {
            let confirmUnfollowAlertVC = UIAlertController(
                title: "Confirm Unfollow",
                message: "Are you sure you want to unfollow @\(user!.username)",
                preferredStyle: .actionSheet
            )
            confirmUnfollowAlertVC.addAction(
                UIAlertAction(
                    title: "Unfollow",
                    style: .destructive,
                    handler: { (action) in
                        self.unfollowUser()
                    }
                )
            )
            confirmUnfollowAlertVC.addAction(
                UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: nil
                )
            )
            parentVC.present(confirmUnfollowAlertVC, animated: true, completion: nil)
        }
    }
    
    
    /**
     
     */
    private func unfollowUser() {
        CurrentUser.unfollow(
            user: user!
        ) { (customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.delegate?.searchUserCellFollowButtonActionError(error: customError)
                    return
                }
                self.followButton.setButtonState(followStatus: self.followStatus)
            }
        }
    }
}
