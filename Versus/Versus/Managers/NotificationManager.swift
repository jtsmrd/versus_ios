//
//  NotificationManager.swift
//  Versus
//
//  Created by JT Smrdel on 6/10/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

protocol NotificationManagerDelegate: class {
    func notificationResultsUpdated(
        notifications: [Notification],
        isNewRequest: Bool
    )
    func didFailWithError(error: String)
}

class NotificationManager {
    
    private let notificationService = NotificationService.instance
    
    private var userId: Int = 0
    private var page = 1
    private var isNewRequest: Bool {
        return page == 1
    }
    private var fetchingInProgress = false
    private(set) var hasMoreResults = false
    private weak var delegate: NotificationManagerDelegate?
    
    init(delegate: NotificationManagerDelegate) {
        self.delegate = delegate
    }
    
    
    private func getUserNotifications(page: Int) {
        guard !fetchingInProgress else { return }
        fetchingInProgress = true
        
        notificationService.getUserNotifications(
            userId: userId,
            page: page
        ) { [weak self] (notifications, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.didFailWithError(
                    error: error
                )
            }
            else {
                self.delegate?.notificationResultsUpdated(
                    notifications: notifications,
                    isNewRequest: self.isNewRequest
                )
                self.hasMoreResults = notifications.count == Config.FETCH_LIMIT
            }
            self.fetchingInProgress = false
        }
    }
    
    
    func getUserNotifications(userId: Int) {
        self.userId = userId
        page = 1
        getUserNotifications(
            page: page
        )
    }
    
    func fetchMoreResults() {
        guard !fetchingInProgress else { return }
        page += 1
        getUserNotifications(page: page)
    }
}
