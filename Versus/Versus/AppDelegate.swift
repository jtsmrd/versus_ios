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

    var window: UIWindow?
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    var signInCredentials: SignInCredentials!
    let SNSPlatformApplicationArn = "arn:aws:sns:us-east-1:853109377079:app/APNS_SANDBOX/VersusSmrdel"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Make sure we're connected to AWS
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        AWSDDLog.sharedInstance.logLevel = .info
        
        // Create AWSMobileClient to connect with AWS
        let interceptReturn = AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Used for Lambda and SNS
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:b80002bd-0582-4a26-80b9-05737c384ef5")
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        if AWSSignInManager.sharedInstance().isLoggedIn && AWSCognitoIdentityUserPool.default().currentUser()?.username == CurrentUser.localUserPoolUserId {
            loadCurrentUser { (success, error) in
                DispatchQueue.main.async {
                    if let customError = error, let customErrorError = customError.error {
                        debugPrint("Unable to load current user: \(customErrorError.localizedDescription)")
                        self.showLogin()
                    }
                    else if success {
                        
                        //TODO: Call from somewhere in the app after user successfully creates account
                        self.registerForPushNotifications()
                        
                        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
                            let aps = notification["aps"] as! [String: AnyObject]
                            self.handleNotification(aps: aps)
                        }
                        else {
                            self.showMain()
                        }
                    }
                    else {
                        self.showChooseUsername()
                    }
                }
            }
        }
        else {
            AWSCognitoIdentityUserPool.default().clearAll()
            showLogin()
        }
        
        return interceptReturn
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
        debugPrint("Device Token: \(token)")
        
        //TODO: Move this to UserDefaults class when created
        UserDefaults.standard.set(token, forKey: "deviceTokenForSNS")
        
        let request: AWSSNSCreatePlatformEndpointInput = AWSSNSCreatePlatformEndpointInput()
        request.token = token
        request.platformApplicationArn = SNSPlatformApplicationArn
        
        AWSSNS.default().createPlatformEndpoint(request).continueWith(executor: AWSExecutor.mainThread()) { (task: AWSTask!) -> Any? in
            if let error = task.error {
                debugPrint("Failed to create AWS platform endpoint: \(error.localizedDescription)")
            }
            else {
                let createEndpointResponse = task.result! as AWSSNSCreateEndpointResponse
                if let endpointArnForSNS = createEndpointResponse.endpointArn {
                    debugPrint("Endpoint Arn: \(endpointArnForSNS)")
                    
                    //TODO: Move this to UserDefaults class when created
                    UserDefaults.standard.set(endpointArnForSNS, forKey: "endpointArnForSNS")
                    
                    //TODO: Save endpointArn to AWSUserEndpointArn
//                    UserService.instance.loadUserSNSEndpointARN(CurrentUser.user.awsUser, completion: { (endpointArnRecord, customError) in
//                        if let error = customError {
//                            debugPrint("Error loading user endpoint arn: \(error.error!)")
//                        }
//                        else if let _ = endpointArnRecord {
//                            //TODO: Check if new endpointARN is different
//                        }
//                        else {
//                            // Save endpoint arn
//                        }
//                    })
                    
                    UserService.instance.saveUserSNSEndpointARN(endpointArnForSNS, CurrentUser.userPoolUserId, completion: { (success, error) in
                        if let error = error {
                            debugPrint("Failed to save User SNS Endpoint ARN: \(error.error!)")
                        }
                        else if success {
                            //TODO: Save value in UserDefaults in order to try again later.
                        }
                        else {
                            debugPrint("Error: Something went wrong when saving endpoint arn")
                        }
                    })
                }
            }
            return nil
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Failed to register for remote notifications: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        handleNotification(aps: aps)
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
    
    private func showChooseUsername() {
        if let chooseUsernameVC = UIStoryboard(name: "Login", bundle: nil)
            .instantiateViewController(withIdentifier: CHOOSE_USERNAME_VC) as? ChooseUsernameVC {
            let navController = UINavigationController()
            navController.isNavigationBarHidden = true
            navController.addChildViewController(chooseUsernameVC)
            window?.rootViewController = navController
            window?.makeKeyAndVisible()
        }
    }
    
    private func loadCurrentUser(completion: @escaping SuccessErrorCompletion) {
        UserService.instance.loadUserWithUserPoolUserId(
            CurrentUser.userPoolUserId
        ) { (user, error) in
            if let error = error {
                completion(false, error)
            }
            else if let user = user {
                CurrentUser.user = user
                completion(true, nil)
            }
            else {
                // User closed app without selecting a usename, which creates a user
                completion(false, nil)
            }
        }
    }
    
    
    
    func prepareForSignIn(signInCredentials: SignInCredentials) {
        self.signInCredentials = signInCredentials
        AWSCognitoUserPoolsSignInProvider.sharedInstance().setInteractiveAuthDelegate(self)
    }
}

extension AppDelegate: AWSCognitoIdentityPasswordAuthentication {

    func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        passwordAuthenticationCompletion = passwordAuthenticationCompletionSource as? AWSTaskCompletionSource<AnyObject>
    }

    func didCompleteStepWithError(_ error: Error?) {
        if let error = error {
            debugPrint("Error password auth step: \(error.localizedDescription)")
        }
    }
}

extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {

    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        return self
    }
}

extension AppDelegate: AWSCognitoUserPoolsSignInHandler {
    
    func handleUserPoolSignInFlowStart() {
        
        appDelegate.passwordAuthenticationCompletion?.set(
            result: AWSCognitoIdentityPasswordAuthenticationDetails(
                username: signInCredentials.username,
                password: signInCredentials.password
            )
        )
    }
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

