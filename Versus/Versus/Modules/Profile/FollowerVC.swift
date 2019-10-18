//
//  FollowerVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class FollowerVC: UIViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var followerTableView: UITableView!
    
    private let followerService = FollowerService.instance
    
    private var user: User!
    private var canEdit = false
    private var followers = [Follower]()
    private var keyboardToolbar: KeyboardToolbar!
    private var indexPathOfLastSelection: IndexPath?
    
    
    
    
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        followerTableView.register(
            UINib(nibName: FOLLOWER_CELL, bundle: nil),
            forCellReuseIdentifier: FOLLOWER_CELL
        )
        
        canEdit = CurrentAccount.userIsMe(userId: user.id)
        keyboardToolbar = KeyboardToolbar(includeNavigation: false)
        loadFollowers(userId: user.id)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        indexPathOfLastSelection = nil
    }
    
    
    
    
    /**
     
     */
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    /**
     
     */
    private func loadFollowers(userId: Int) {
        
        followerService.loadFollowers(
            userId: userId
        ) { [weak self] (followers, errorMessage) in
            
            DispatchQueue.main.async {
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                guard let followers = followers else {
                    self?.displayMessage(message: "Unable to load followers")
                    return
                }
                
                self?.followers = followers
                self?.followerTableView.reloadData()
            }
        }
    }
    
    
    /**
     
     */
    private func filterFollowers(filter: String) {
        
//        guard !filter.isEmpty else {
//            filteredFollowers = nil
//            followerTableView.reloadData()
//            return
//        }
//        filteredFollowers = allFollowers.filter({ $0.searchUsername.contains(filter.lowercased()) || $0.searchDisplayName.contains(filter.lowercased()) })
//        followerTableView.reloadData()
    }
    
    
    /**
     
     */
    private func showFollowerProfileAt(indexPath: IndexPath) {
        
        let user = followers[indexPath.row].user
        let delegate = canEdit ? self : nil
        
        let userVC = UserVC(
            user: user,
            delegate: delegate
        )
        navigationController?.pushViewController(
            userVC,
            animated: true
        )
    }
    
    
    private func followUser(indexPath: IndexPath) {
        
        let user = followers[indexPath.row].user
        
        followerService.followUser(
            userId: user.id
        ) { [weak self] (errorMessage) in
            
            DispatchQueue.main.async {
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                CurrentAccount.addFollowedUserId(id: user.id)
                
                self?.followerTableView.reloadRows(
                    at: [indexPath],
                    with: .automatic
                )
            }
        }
    }
    
    
    private func unfollowUser(indexPath: IndexPath) {
        
        let user = followers[indexPath.row].user
        
        let unfollowAlert = UIAlertController(
            title: "Confirm Unfollow",
            message: "Are you sure you want to unfollow @\(user.username)",
            preferredStyle: .actionSheet
        )
        
        let unfollowAction = UIAlertAction(
            title: "Unfollow",
            style: .destructive
        ) { (action) in
            
            self.loadAndUnfollowUser(indexPath: indexPath)
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        unfollowAlert.addAction(unfollowAction)
        unfollowAlert.addAction(cancelAction)
        
        present(
            unfollowAlert,
            animated: true,
            completion: nil
        )
    }
    
    
    private func loadAndUnfollowUser(indexPath: IndexPath) {
        
        let userId = CurrentAccount.user.id
        let userFollowed = followers[indexPath.row].user
        
        followerService.getFollowedUser(
            userId: userId,
            followedUserId: userFollowed.id
        ) { [weak self] (followedUser, errorMessage) in
            
            if let errorMessage = errorMessage {
                DispatchQueue.main.async {
                    self?.displayMessage(message: errorMessage)
                }
                return
            }
            
            guard let followedUser = followedUser else {
                DispatchQueue.main.async {
                    self?.displayMessage(message: "Unable to unfollow user")
                }
                return
            }
            
            self?.followerService.unfollow(
                followerId: followedUser.id,
                completion: { [weak self] (errorMessage) in
                    
                    DispatchQueue.main.async {
                        
                        if let errorMessage = errorMessage {
                            self?.displayMessage(message: errorMessage)
                            return
                        }
                        
                        CurrentAccount.removeFollowedUserId(id: userFollowed.id)
                        
                        self?.followerTableView.reloadRows(
                            at: [indexPath],
                            with: .automatic
                        )
                    }
                }
            )
        }
    }
}




extension FollowerVC: UserVCDelegate {
    
    
    func userUpdated() {
        
        guard let indexPath = indexPathOfLastSelection else {
            return
        }
        
        followerTableView.reloadRows(
            at: [indexPath],
            with: .none
        )
    }
}




extension FollowerVC: UISearchBarDelegate {
    
    /**
     
     */
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.inputAccessoryView = keyboardToolbar
        return true
    }
    
    /**
     
     */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    /**
     
     */
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
//        if followers.isEmpty {
//            searchBar.text?.removeAll()
//            filteredFollowers = nil
//            followerTableView.reloadData()
//        }
    }
    
    /**
     
     */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text?.removeAll()
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
        
//        filteredFollowers = nil
//        followerTableView.reloadData()
    }
    
    /**
     
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFollowers(filter: searchText)
    }
}




extension FollowerVC: FollowerCellDelegate {
    
    
    func followUserAt(cell: UITableViewCell) {
        
        if let indexPath = followerTableView.indexPath(for: cell) {
            followUser(indexPath: indexPath)
        }
    }
    
    
    func unfollowUserAt(cell: UITableViewCell) {
        
        if let indexPath = followerTableView.indexPath(for: cell) {
            unfollowUser(indexPath: indexPath)
        }
    }
}




extension FollowerVC: UITableViewDataSource {
    
    
    /**
     
     */
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        return followers.count
    }
    
    
    /**
     
     */
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FOLLOWER_CELL,
            for: indexPath
        )
        
        if let followerCell = cell as? FollowerCell {
            
            let follower = followers[indexPath.row]
            //TODO
            followerCell.configureCell(
                follower: follower,
                delegate: self,
                profileImage: nil
            )
            return followerCell
        }
        return FollowerCell()
    }
    
    
    /**
     
     */
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        return 70
    }
}




extension FollowerVC: UITableViewDelegate {
    
    /**
     
     */
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        indexPathOfLastSelection = indexPath
        
        tableView.deselectRow(
            at: indexPath,
            animated: false
        )
        
        showFollowerProfileAt(indexPath: indexPath)
    }
}
