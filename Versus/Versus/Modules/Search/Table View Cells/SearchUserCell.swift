//
//  SearchUserCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/11/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

protocol SearchUserCellDelegate {
    func followUserAt(cell: UITableViewCell)
    func unfollowUserAt(cell: UITableViewCell)
}

class SearchUserCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    private var delegate: SearchUserCellDelegate?
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
    
    
    
    
    /**
     
     */
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
        user: User,
        delegate: SearchUserCellDelegate,
        profileImage: UIImage?
    ) {
        
        self.delegate = delegate
        
        if CurrentAccount.userIsMe(userId: user.id) {
            followButton.isHidden = true
        }
        else {
            followStatus = CurrentAccount.getFollowStatusFor(userId: user.id)
            followButton.setButtonState(followStatus: followStatus)
        }
        
        usernameLabel.text = user.username
        displayNameLabel.text = user.name
        profileImageView.image = profileImage
    }
}
