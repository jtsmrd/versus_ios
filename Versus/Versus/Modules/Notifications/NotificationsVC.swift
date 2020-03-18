//
//  NotificationsVC.swift
//  Versus
//
//  Created by JT Smrdel on 5/14/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController {
    
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var noNotificationsView: UIView!
    
    private let notificationService = NotificationService.instance
    private let userService = UserService.instance
    
    private var notifications = [Notification]()
    private var notificationsRefreshControl: UIRefreshControl!
    
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationsTableView.register(
            UINib(nibName: NOTIFICATION_CELL, bundle: nil),
            forCellReuseIdentifier: NOTIFICATION_CELL
        )
        
        let attributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)]
        let refreshTitle = NSAttributedString(string: "Loading Notifications", attributes: attributes)
        
        notificationsRefreshControl = UIRefreshControl()
        notificationsRefreshControl.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        notificationsRefreshControl.attributedTitle = refreshTitle
        notificationsRefreshControl.addTarget(self, action: #selector(NotificationsVC.getNotifications), for: .valueChanged)
        notificationsTableView.refreshControl = notificationsRefreshControl
        
        notificationsRefreshControl.beginRefreshing()
        getNotifications()
    }
    
    
    /**
     
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If there were no previous notifications and the user navigates back to this screen
        // check for notifications
        if noNotificationsView.isHidden == false {
            getNotifications()
        }
    }

    
    /**
     
     */
    @objc func getNotifications() {
        
        notificationService.getUserNotifications(
            userId: CurrentAccount.user.id
        ) { [weak self] (notifications, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.displayMessage(message: error)
                }
                
                self.notifications = notifications
                self.notificationsTableView.reloadData()
                self.notificationsTableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    
    
    private func showFollowerProfile(notification: Notification) {
        
        let followerNotificationInfo = notification.notificationPayload as! FollowerNotificationInfo
        
        userService.loadUser(
            userId: followerNotificationInfo.followerUserId
        ) { [weak self] (user, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.displayMessage(message: error)
                }
                else if let user = user {
                    
                    let userVC = UserVC(user: user)
                    userVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(
                        userVC,
                        animated: true
                    )
                }
                else {
                    self.displayMessage(
                        message: "Unable to load follower"
                    )
                }
            }
        }
    }
}


extension NotificationsVC: UITableViewDataSource {
    
    
    /**
     
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let notificationsCount = notifications.count
        noNotificationsView.isHidden = notificationsCount > 0 ? true : false
        return notificationsCount
    }
    
    
    /**
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: NOTIFICATION_CELL,
            for: indexPath
        ) as! NotificationCell
        
        let notification = notifications[indexPath.row]
        cell.configureCell(notification: notification)
        return cell
    }
}

extension NotificationsVC: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 80
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = notifications[indexPath.row]
        
        notificationService.setNotificationViewed(
            notification: notification
        ) { [weak self] (notification, error) in
            guard let self = self else { return }
            
            if let notification = notification {
                self.notifications[indexPath.row] = notification
                
                DispatchQueue.main.async {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        switch notification.type.typeEnum {
            
        case .newFollower:
            showFollowerProfile(notification: notification)
            
        case .competitionMatched:
            return
        case .newVote:
            return
        case .competitionWon:
            return
        case .competitionLost:
            return
        case .rankUp:
            return
        case .leaderboard:
            return
        case .topLeader:
            return
        case .newFollowedUserCompetition:
            return
        case .newComment:
            return
        case .newDirectMessage:
            return
        }
    }
    
    
    /**
     
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            let notificationToDelete = notifications[indexPath.row]
//            notificationToDelete.delete { (customError) in
//                DispatchQueue.main.async {
//                    if let customError = customError {
//                        self.displayError(error: customError)
//                        return
//                    }
//                    self.notifications.remove(at: indexPath.row)
//                    self.notificationManager.removeNotification(notification: notificationToDelete)
//                    self.notificationsTableView.deleteRows(at: [indexPath], with: .fade)
//                }
//            }
        }
    }
}
