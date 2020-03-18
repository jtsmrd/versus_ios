//
//  AppDelegate.swift
//  Versus
//
//  Created by JT Smrdel on 3/30/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSAuthCore
import AWSCore
import AWSCognitoIdentityProvider
import AWSUserPoolsSignIn
import AWSSNS
import UserNotifications

let appDelegate = (UIApplication.shared.delegate as! AppDelegate)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let userService = UserService.instance
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Make sure we're connected to AWS
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        AWSDDLog.sharedInstance.logLevel = .info
        
        // Create AWSMobileClient to connect with AWS
//        let interceptReturn = AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Used for Lambda and SNS
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:b80002bd-0582-4a26-80b9-05737c384ef5")
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        showInitialView(launchOptions)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Clear the app badge number
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        let user = CurrentAccount.user
        user.apnsToken = token
        
        userService.updateUser(user: user) { (user, error) in
            // todo: Log error if exists
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Failed to register for remote notifications: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        handleNotification(aps: aps)
    }
    
    /*
     Checks the sign in status and the CurrentUser, then navigates to login, main view, or choose username.
    */
    func showInitialView(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        if !CurrentAccount.tutorialDisplayed {
            showTutorial()
            return
        }
        
        // TODO
        // Try to get user's account
        if CurrentAccount.lastSignedInUserId != 0 && !CurrentAccount.lastAccessToken.isEmpty {
            
            let userId = CurrentAccount.lastSignedInUserId
            let token = CurrentAccount.lastAccessToken
            
            CurrentAccount.setToken(token: token)
            
            userService.loadUser(
                userId: userId
            ) { [weak self] (user, errorMessage) in
                
                guard errorMessage == nil else {
                    
                    DispatchQueue.main.async {
                        self?.showLogin()
                    }                    
                    return
                }
                
                guard let user = user else {
                    return
                }
                
                CurrentAccount.setUser(user: user)
                
                DispatchQueue.main.async {
                    self?.showMain()
                }
            }
        }
        else {
            showLogin()
        }
    }
    
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            
            guard granted else { return }
            self.getNotificationSettings()
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            debugPrint("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    
    
    private func handleNotification(aps: [String: AnyObject]) {
        
        //TODO: Navigate to appropriate view, not main
        DispatchQueue.main.async {
            self.showMain()
        }
    }
    
    private func showTutorial() {
        let tutorialVC = UIStoryboard(name: "Tutorial", bundle: nil).instantiateInitialViewController()
        window?.rootViewController = tutorialVC
        window?.makeKeyAndVisible()
    }
    
    private func showMain() {
        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window = UIWindow()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    private func showLogin() {
        let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
        window?.rootViewController = loginVC
        window?.makeKeyAndVisible()
    }
    
//    private func loadCurrentUser(completion: @escaping SuccessErrorCompletion) {
//
//        UserService.instance.getUser(
//            userId: CurrentUser.lastSignedInUserId
//        ) { (awsUser, error) in
//            if let error = error {
//                completion(false, error)
//            }
//            else if let awsUser = awsUser {
//                CurrentUser.setAWSUser(awsUser: awsUser)
//                completion(true, nil)
//            }
//            else {
//                // User closed app without selecting a usename, which creates a user
//                completion(false, nil)
//            }
//        }
//    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Called when a notification is delivered to a foreground app.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        debugPrint("willPresent notification User Info: \(notification.request.content.userInfo)")
        completionHandler([.alert, .badge, .sound])
    }
    
    
    // Called to let your app know which action was selected by the user for a given notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        
        debugPrint("didReceive response User Info: \(response.notification.request.content.userInfo)")
    }
}

