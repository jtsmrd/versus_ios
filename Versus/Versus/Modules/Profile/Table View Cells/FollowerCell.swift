//
//  FollowerCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol FollowerCellDelegate {
    func followUserAt(cell: UITableViewCell)
    func unfollowUserAt(cell: UITableViewCell)
}

class FollowerCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    private var delegate: FollowerCellDelegate?
    private var followStatus: FollowStatus = .notFollowing
    
    
    
    
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
    
    
    
    
    @IBAction func followButtonAction() {
        
        switch followStatus {
            
        case .following:
            delegate?.unfollowUserAt(cell: self)
            
        case .notFollowing:
            delegate?.followUserAt(cell: self)
        }
    }
    
    
    
    
    /**
     
     */
    func configureCell(
        follower: Follower,
        delegate: FollowerCellDelegate,
        profileImage: UIImage?
    ) {
        
        self.delegate = delegate
        
        if CurrentAccount.userIsMe(userId: follower.user.id) {
            followButton.isHidden = true
        }
        else {
            followStatus = CurrentAccount.getFollowStatusFor(userId: follower.user.id)
            followButton.setButtonState(followStatus: followStatus)
        }
        
        usernameLabel.text = follower.user.username
        displayNameLabel.text = follower.user.name
        profileImageView.image = profileImage
    }
}
