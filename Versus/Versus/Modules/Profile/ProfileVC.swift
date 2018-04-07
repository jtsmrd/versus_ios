//
//  ProfileVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/3/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import AWSUserPoolsSignIn

class ProfileVC: UIViewController {

    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: CircleImageView!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followingContainerView: BorderView!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersContainerView: BorderView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var rankContainerView: BorderView!
    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var competitionCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func optionsButtonAction() {
        guard let username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username else {
            debugPrint("AWS user username nil")
            return
        }
        
        UserService.instance.createUser(userPoolUserId: username, username: "JTSmrd")
    }
    
    @IBAction func directMessageButtonAction() {
        AWSSignInManager.sharedInstance().logout { (anyVal, error) in
            
        }
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
