//
//  NotificationsVC.swift
//  Versus
//
//  Created by JT Smrdel on 5/14/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var noNotificationsView: UIView!
    
    
    // MARK: - Constants
    
    private let userService = UserService.instance
    private let notificationService = NotificationService.instance
    private let PREFETCH_SCROLL_PERCENTAGE: CGFloat = 0.50
    
    
    // MARK: - Variables
    
    private var notifications = [Notification]()
    private var notificationManager: NotificationManager!
    private var pendingImageOperations = ImageOperations()
    private var notificationsRefreshControl: UIRefreshControl!
    
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationManager = NotificationManager(delegate: self)
        
        notificationsTableView.register(
            UINib(nibName: NOTIFICATION_CELL, bundle: nil),
            forCellReuseIdentifier: NOTIFICATION_CELL
        )
        
        let attributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)]
        let refreshTitle = NSAttributedString(string: "Loading Notifications", attributes: attributes)
        
        notificationsRefreshControl = UIRefreshControl()
        notificationsRefreshControl.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        notificationsRefreshControl.attributedTitle = refreshTitle
        notificationsRefreshControl.addTarget(
            self,
            action: #selector(
                NotificationsVC.getNotifications
            ),
            for: .valueChanged
        )
        notificationsTableView.refreshControl = notificationsRefreshControl
        
        notificationsRefreshControl.beginRefreshing()
        getNotifications()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If there were no previous notifications and the user navigates back to this screen
        // check for notifications
        if noNotificationsView.isHidden == false {
            getNotifications()
        }
    }

    
    
    @objc func getNotifications() {
        let userId = CurrentAccount.user.id
        notificationManager.getUserNotifications(userId: userId)
    }
    
    
    
    private func setNotificationViewed(
        notification: Notification,
        indexPath: IndexPath
    ) {
        notificationService.setNotificationViewed(
            notification: notification
        ) { [weak self] (notification, error) in
            guard let self = self else { return }
            
            if let notification = notification {
                self.notifications[indexPath.row] = notification
                
                DispatchQueue.main.async {
                    self.notificationsTableView.reloadRows(
                        at: [indexPath],
                        with: .none
                    )
                }
            }
        }
    }
    
    
    private func deleteNotification(
        notification: Notification,
        indexPath: IndexPath
    ) {
        notificationService.deleteNotification(
            notification: notification
        ) { [weak self] (error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.displayMessage(message: error)
                }
                else {
                    self.notifications.remove(at: indexPath.row)
                    self.notificationsTableView.beginUpdates()
                    self.notificationsTableView.deleteRows(
                        at: [indexPath],
                        with: .fade
                    )
                    self.notificationsTableView.endUpdates()
                }
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
    
    
    // MARK: - Image Operations
    
    private func startNotificationImageDownloadFor(
        notification: Notification,
        indexPath: IndexPath
    ) {
        var downloadsInProgress = pendingImageOperations.asyncDownloadsInProgress

        // Make sure there isn't already a download in progress.
        guard downloadsInProgress[indexPath] == nil else { return }

        let downloadOperation = DownloadNotificationImageOperation(
            notification: notification
        )

        downloadOperation.completionBlock = {

            if downloadOperation.isCancelled { return }

            DispatchQueue.main.async {

                downloadsInProgress.removeValue(
                    forKey: indexPath
                )

                if let notificationCell = self.notificationsTableView.cellForRow(at: indexPath) as? NotificationCell {
                    notificationCell.updateImage()
                }
            }
        }

        // Add the operation to the collection of downloads in progress.
        downloadsInProgress[indexPath] = downloadOperation

        // Add the operation to the queue to start downloading.
        pendingImageOperations.asyncDownloadQueue.addOperation(
            downloadOperation
        )
    }
}


extension NotificationsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let notificationsCount = notifications.count
        noNotificationsView.isHidden = notificationsCount > 0 ? true : false
        return notificationsCount
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: NOTIFICATION_CELL,
            for: indexPath
        ) as! NotificationCell
        
        let notification = notifications[indexPath.row]
        cell.configureCell(
            notification: notification
        )
        
        if notification.imageDownloadState == .new {
            startNotificationImageDownloadFor(
                notification: notification,
                indexPath: indexPath
            )
        }
        
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
        
        setNotificationViewed(
            notification: notification,
            indexPath: indexPath
        )
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let notification = notifications[indexPath.row]
            deleteNotification(
                notification: notification,
                indexPath: indexPath
            )
        }
    }
}


private extension NotificationsVC {

    private func calculateIndexPathsToReload(
        from newNotifications: [Notification]
    ) -> [IndexPath] {
        
        let startIndex = notifications.count - newNotifications.count
        let endIndex = startIndex + newNotifications.count
        let indexPaths = (startIndex..<endIndex).map {
            IndexPath(row: $0, section: 0)
        }
        
        return indexPaths
    }
    
    func visibleIndexPathsToReload(
        intersecting indexPaths: [IndexPath]
    ) -> [IndexPath] {
        
        let indexPathsForVisibleRows = notificationsTableView.indexPathsForVisibleRows ?? []
        
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        
        return Array(indexPathsIntersection)
    }
}


extension NotificationsVC: NotificationManagerDelegate {
    
    func notificationResultsUpdated(
        notifications: [Notification],
        isNewRequest: Bool
    ) {
        if isNewRequest {
            self.notifications = notifications
        }
        else {
            self.notifications.append(contentsOf: notifications)
        }
        
        DispatchQueue.main.async {
            
            var newIndexPathsToReload: [IndexPath]?
            if !isNewRequest {
                newIndexPathsToReload = self.calculateIndexPathsToReload(
                    from: notifications
                )
            }
            
            guard let newIndexPaths = newIndexPathsToReload else {
                self.notificationsTableView.refreshControl?.endRefreshing()
                self.notificationsTableView.reloadData()
                return
            }
            
            self.notificationsTableView.beginUpdates()
            self.notificationsTableView.insertRows(
                at: newIndexPaths,
                with: .none
            )
            self.notificationsTableView.endUpdates()
        }
    }
    
    func didFailWithError(error: String) {
        DispatchQueue.main.async {
            self.displayMessage(message: error)
        }
    }
}


// MARK: - UITableViewDataSourcePrefetching

extension NotificationsVC: UITableViewDataSourcePrefetching {
    
    func tableView(
        _ tableView: UITableView,
        prefetchRowsAt indexPaths: [IndexPath]
    ) {
        // No need to fetch if there are no more results
        guard notificationManager.hasMoreResults else { return }
        
        // Get the row number of the last visible row
        guard let maxVisibleRowNumber =
            tableView.indexPathsForVisibleRows?.max()?.row else { return }
        
        // Calculate the percentage of total rows that are scolled to
        let scrollPercentage = CGFloat(maxVisibleRowNumber) / CGFloat(notifications.count)
        
        // Only prefetch when the scrolled percentage is >= 85%
        guard scrollPercentage >= PREFETCH_SCROLL_PERCENTAGE else { return }
        
        notificationManager.fetchMoreResults()
    }
}
