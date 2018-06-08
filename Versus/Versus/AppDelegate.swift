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

let appDelegate = (UIApplication.shared.delegate as! AppDelegate)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    var signInCredentials: SignInCredentials!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Make sure we're connected to AWS
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        AWSDDLog.sharedInstance.logLevel = .info
        
        // Create AWSMobileClient to connect with AWS
        let interceptReturn = AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        if AWSSignInManager.sharedInstance().isLoggedIn {
            loadCurrentUser { (success, error) in
                DispatchQueue.main.async {
                    if let customError = error, let customErrorError = customError.error {
                        debugPrint("Unable to load current user: \(customErrorError.localizedDescription)")
                        self.showLogin()
                    }
                    else if success {
                        self.showMain()
                    }
                    else {
                        self.showChooseUsername()
                    }
                }
            }
        }
        else {
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
        UserService.instance.loadUser(userPoolUserId: CurrentUser.userPoolUserId) { (awsUser, error) in
            if let error = error {
                completion(false, error)
            }
            else if let awsUser = awsUser {
                CurrentUser.user = User(awsUser: awsUser)
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

