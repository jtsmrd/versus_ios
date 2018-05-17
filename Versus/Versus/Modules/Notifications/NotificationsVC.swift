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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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


extension NotificationsVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentUser.notifications.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: NOTIFICATION_CELL, for: indexPath) as? NotificationCell {
            cell.configureCell(notification: CurrentUser.notifications[indexPath.row])
            return cell
        }
        return NotificationCell()
    }
    
    
}

extension NotificationsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
