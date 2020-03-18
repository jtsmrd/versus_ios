//
//  FollowerVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

enum FollowerType {
    case follower
    case followedUser
}

class FollowerVC: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var followerTableView: UITableView!
    
    
    private let followerService = FollowerService.instance
    
    
    private var userId: Int!
    private var followerType: FollowerType!
    private var followers = [Follower]()
    private var keyboardToolbar: KeyboardToolbar!
    private var indexPathOfLastSelection: IndexPath?
    
    
    
    init(userId: Int, followerType: FollowerType) {
        super.init(nibName: nil, bundle: nil)
        
        self.userId = userId
        self.followerType = followerType
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
        
        switch followerType {
        case .follower:
            titleLabel.text = "Followers"
            
        case .followedUser:
            titleLabel.text = "Followed Users"
            
        default:
            break
        }
        
        keyboardToolbar = KeyboardToolbar(includeNavigation: false)
        
        loadUsers(userId: userId)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        indexPathOfLastSelection = nil
    }
    
    
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    
    private func loadUsers(userId: Int) {
        
        switch followerType {
        case .follower:
            loadFollowers(userId: userId)
            
        case .followedUser:
            loadFollowedUsers(userId: userId)
            
        default:
            return
        }
    }
    
    
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
    
    
    private func loadFollowedUsers(userId: Int) {
        
        followerService.loadFollowedUsers(
            userId: userId
        ) { [weak self] (followers, errorMessage) in
            
            DispatchQueue.main.async {
                
                if let errorMessage = errorMessage {
                    self?.displayMessage(message: errorMessage)
                    return
                }
                
                guard let followers = followers else {
                    self?.displayMessage(message: "Unable to load followed users")
                    return
                }
                
                self?.followers = followers
                self?.followerTableView.reloadData()
            }
        }
    }
    
    
    private func filterFollowers(filter: String) {
        
//        guard !filter.isEmpty else {
//            filteredFollowers = nil
//            followerTableView.reloadData()
//            return
//        }
//        filteredFollowers = allFollowers.filter({ $0.searchUsername.contains(filter.lowercased()) || $0.searchDisplayName.contains(filter.lowercased()) })
//        followerTableView.reloadData()
    }
    
    
    
    private func showFollowerProfileAt(indexPath: IndexPath) {
        
        var user: User!
        
        switch followerType {
        case .follower:
            user = followers[indexPath.row].user
            
        case .followedUser:
            user = followers[indexPath.row].followedUser
            
        default:
            return
        }
        
        let userVC = UserVC(
            user: user,
            delegate: self
        )
        navigationController?.pushViewController(
            userVC,
            animated: true
        )
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
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.inputAccessoryView = keyboardToolbar
        return true
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
//        if followers.isEmpty {
//            searchBar.text?.removeAll()
//            filteredFollowers = nil
//            followerTableView.reloadData()
//        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text?.removeAll()
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
        
//        filteredFollowers = nil
//        followerTableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterFollowers(filter: searchText)
    }
}



extension FollowerVC: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        return followers.count
    }
    
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FOLLOWER_CELL,
            for: indexPath
        ) as! FollowerCell
        
        let follower = followers[indexPath.row]
        //TODO
        cell.configureCell(
            follower: follower,
            followerType: followerType
        )
        return cell
    }
    
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        return 70
    }
}




extension FollowerVC: UITableViewDelegate {
    
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
