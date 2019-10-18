//
//  RankCell.swift
//  Versus
//
//  Created by JT Smrdel on 4/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class RankCell: UITableViewCell {

    
    @IBOutlet weak var userRankView: UserRankView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var rankTitleLabel: UILabel!
    @IBOutlet weak var winsRequirementLabel: UILabel!
    @IBOutlet weak var votesRequirementLabel: UILabel!
    @IBOutlet weak var rankImageView: UIImageView!
    
    private let s3BucketService = S3BucketService.instance
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = nil
        winsLabel.text = nil
        votesLabel.text = nil
        rankTitleLabel.text = nil
        winsRequirementLabel.text = nil
        votesRequirementLabel.text = nil
        rankImageView.image = nil
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    
    
    func configureCell(
        user: User,
        rank: Rank
    ) {
        
        userRankView.isHidden = user.rank.id != rank.id
        winsLabel.text = String(format: "%d Wins", user.totalWins)
        votesLabel.text = String(format: "%d Votes", user.totalTimesVoted)
        rankTitleLabel.text = rank.title
        winsRequirementLabel.text = "10+ Wins"
        votesRequirementLabel.text = "10+ Votes"
        rankImageView.image = rank.image
        
        downloadProfileImage(user: user)
    }
    
    
    
    
    private func downloadProfileImage(user: User) {
        
        if !user.profileImage.isEmpty {
            
            s3BucketService.downloadImage(
                mediaId: user.profileImage,
                imageType: .regular
            ) { [weak self] (image, customError) in
                
                DispatchQueue.main.async {
                    
                    if customError != nil {
                        self?.parentViewController?.displayMessage(
                            message: "Unable to download profile image"
                        )
                        return
                    }
                    
                    self?.profileImageView.image = image
                }
            }
        }
    }
}
