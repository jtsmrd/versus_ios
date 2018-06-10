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
    
    var notifications = [Notification]()
    var notificationsRefreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notifications = NotificationManager.instance.notifications
        
        let attributes = [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)]
        let refreshTitle = NSAttributedString(string: "Loading Notifications", attributes: attributes)
        
        notificationsRefreshControl = UIRefreshControl()
        notificationsRefreshControl.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        notificationsRefreshControl.attributedTitle = refreshTitle
        notificationsRefreshControl.addTarget(self, action: #selector(NotificationsVC.getNotifications), for: .valueChanged)
        notificationsTableView.refreshControl = notificationsRefreshControl
        
        notificationsRefreshControl.beginRefreshing()
        getNotifications()
    }

    
    @objc func getNotifications() {
        NotificationManager.instance.getCurrentUserNotifications { (notifications, customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.displayError(error: customError)
                }
                else {
                    self.notifications = notifications
                    self.notificationsTableView.reloadData()
                    self.notificationsTableView.refreshControl?.endRefreshing()
                }
            }
        }
        notificationsTableView.reloadData()
    }
    
    
    private func showFollowerProfile(_ notification: Notification) {
        
        guard let notificationInfo = notification.notificationInfo as? FollowerNotificationInfo else {
            self.displayMessage(message: "Could not load follower data.")
            return
        }
        
        UserService.instance.loadUser(notificationInfo.followerUsername) { (user, customError) in
            if let customError = customError {
                self.displayError(error: customError)
            }
            else if let user = user {
                
                if let profileVC = UIStoryboard(name: PROFILE, bundle: nil).instantiateViewController(withIdentifier: PROFILE_VC) as? ProfileVC {
                    profileVC.initData(profileViewMode: .viewOnly, user: user)
                    profileVC.hidesBottomBarWhenPushed = true
                    
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(profileVC, animated: true)
                    }
                }
                
                self.updateNotificationWasViewedStatus(notification: notification)
            }
            else {
                debugPrint("Something else went wrong.")
            }
        }
    }
    
    
    private func updateNotificationWasViewedStatus(notification: Notification) {
        
        NotificationService.instance.setNotificationWasViewed(notification) { (success, customError) in
            DispatchQueue.main.async {
                if let customError = customError {
                    self.displayError(error: customError)
                }
                else {
                    self.notificationsTableView.reloadData()
                }
            }
        }
    }
}


extension NotificationsVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: NOTIFICATION_CELL, for: indexPath) as? NotificationCell {
            cell.configureCell(notification: notifications[indexPath.row])
            return cell
        }
        return NotificationCell()
    }
    
    
}

extension NotificationsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = notifications[indexPath.row]
        
        switch notification.notificationType {
        case .follower:
            showFollowerProfile(notification)
        case .competitionComment:
            return
        case .competitionLost:
            return
        case .competitionRemoved:
            return
        case .competitionStarted:
            return
        case .competitionWon:
            return
        case .rankUp:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notificationToDelete = notifications[indexPath.row]
            NotificationService.instance.deleteNotification(notification: notificationToDelete) { (success, customError) in
                DispatchQueue.main.async {
                    if let customError = customError {
                        self.displayError(error: customError)
                    }
                    else {
                        self.notifications.remove(at: indexPath.row)
                        self.notificationsTableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
}
