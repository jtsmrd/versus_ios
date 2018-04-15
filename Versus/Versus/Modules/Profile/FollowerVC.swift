//
//  FollowerVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum FollowersViewType: String {
    case following = "Following"
    case follower = "Followers"
}

enum FollowersViewMode {
    case edit
    case viewOnly
}

class FollowerVC: UIViewController {

    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var followerTableView: UITableView!
    
    
    var followersViewType: FollowersViewType = .following
    var followerViewMode: FollowersViewMode = .viewOnly
    var followers = [Follower]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        followerTableView.reloadData()
    }

    
    func initData(followersViewType: FollowersViewType, followerViewMode: FollowersViewMode, followers: [Follower]) {
        self.followersViewType = followersViewType
        self.followerViewMode = followerViewMode
        self.followers = followers
    }
    
    
    private func configureView() {
        
        viewTitleLabel.text = followersViewType.rawValue
    }
    
    
    private func showFollowerProfile(follower: Follower) {
        
        UserService.instance.loadUser(fromFollower: follower) { (awsUser, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.displayError(error: error)
                }
                else if let awsUser = awsUser {
                    if let profileVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                        profileVC.initData(profileViewMode: .viewOnly, user: User(awsUser: awsUser))
                        profileVC.delegate = self.followerViewMode == .edit ? self : nil
                        profileVC.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(profileVC, animated: true)
                    }
                }
            }
        }
    }
    
    
    private func removeRow(at index: Int) {
        followers.remove(at: index)
        DispatchQueue.main.async {
            self.followerTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .top)
        }
    }
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FollowerVC: ProfileVCDelegate {
    
    func unfollowedUser(user: User) {
        if followerViewMode == .edit,
            followersViewType == .following,
            let index = followers.index(where: {$0.awsFollower._followedUserId == user.awsUser._userPoolUserId}) {
            removeRow(at: index)
        }
    }
}

extension FollowerVC: UISearchBarDelegate {
    
}

extension FollowerVC: FollowerCellDelegate {
    
    func followerCellFollowButtonActionError(error: CustomError) {
        displayError(error: error)
    }
    
    func followerCellFollowButtonActionUnfollow(follower: Follower) {
        
        if followerViewMode == .edit,
            followersViewType == .following,
            let index = followers.index(where: {$0.awsFollower._id == follower.awsFollower._id}) {
            removeRow(at: index)
        }
        FollowerService.instance.removeFollowerFromFollowedUsers(user: CurrentUser.user, awsFollower: follower.awsFollower)
    }
}

extension FollowerVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FOLLOWER_CELL, for: indexPath) as? FollowerCell {
            cell.configureCell(follower: followers[indexPath.row], delegate: self)
            return cell
        }
        return FollowerCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension FollowerVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showFollowerProfile(follower: followers[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
