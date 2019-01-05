//
//  NotificationsVC.swift
//  Versus
//
//  Created by JT Smrdel on 5/14/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController {

    private let notificationService = NotificationService.instance
    private let notificationManager = NotificationManager.instance
    
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var noNotificationsView: UIView!
    
    var notifications = [VersusNotification]()
    var notificationsRefreshControl: UIRefreshControl!
    
    
    /**
 
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notifications = notificationManager.notifications
        
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
    
    
    /**
     
     */
    private func showFollowerProfile(_ notification: VersusNotification) {
        
        guard let notificationInfo = notification.notificationInfo as? FollowerNotificationInfo else {
            self.displayMessage(message: "Could not load follower data.")
            return
        }
        
        if let profileVC = UIStoryboard(name: PROFILE, bundle: nil).instantiateViewController(withIdentifier: PROFILE_VC) as? ProfileVC {
            profileVC.initData(userId: notificationInfo.userId, profileViewMode: .viewOnly)
            profileVC.hidesBottomBarWhenPushed = true
            
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(profileVC, animated: true)
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: NOTIFICATION_CELL, for: indexPath) as? NotificationCell {
            cell.configureCell(notification: notifications[indexPath.row])
            return cell
        }
        return NotificationCell()
    }
}

extension NotificationsVC: UITableViewDelegate {
    
    
    /**
     
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    /**
     
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = notifications[indexPath.row]
        notification.markViewed(completion: nil)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
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
    
    
    /**
     
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let notificationToDelete = notifications[indexPath.row]
            notificationToDelete.delete { (customError) in
                DispatchQueue.main.async {
                    if let customError = customError {
                        self.displayError(error: customError)
                        return
                    }
                    self.notifications.remove(at: indexPath.row)
                    self.notificationManager.removeNotification(notification: notificationToDelete)
                    self.notificationsTableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
}
