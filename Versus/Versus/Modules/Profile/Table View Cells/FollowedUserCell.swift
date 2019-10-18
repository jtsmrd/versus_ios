//
//  FollowedUserCell.swift
//  Versus
//
//  Created by JT Smrdel on 8/15/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol FollowedUserCellDelegate {
    func unfollowUserAt(cell: UITableViewCell)
}

class FollowedUserCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    private var delegate: FollowedUserCellDelegate?
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = nil
        usernameLabel.text = nil
        displayNameLabel.text = nil
        delegate = nil
    }

    
    
    
    /**
 
     */
    @IBAction func unfollowButtonAction() {
        
        delegate?.unfollowUserAt(cell: self)
    }
    
    
    
    
    /**
     
     */
    func configureCell(
        followedUser: FollowedUser,
        delegate: FollowedUserCellDelegate,
        profileImage: UIImage?
    ) {
        
        self.delegate = delegate
        
        if CurrentAccount.userIsMe(userId: followedUser.user.id) {
            followButton.isHidden = true
        }
        else {
            followButton.setButtonState(followStatus: .following)
        }
        
        usernameLabel.text = followedUser.user.username
        displayNameLabel.text = followedUser.user.name
        profileImageView.image = profileImage
    }
}
