//
//  MainTBC.swift
//  Versus
//
//  Created by JT Smrdel on 4/17/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class MainTBC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        let tabBarHeight = tabBar.frame.size.height
        
        let circleView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tabBarHeight * 0.95, height: tabBarHeight * 0.95))
        circleView.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 0.5)
        circleView.layer.cornerRadius = circleView.frame.height / 2
        circleView.clipsToBounds = true
        circleView.center = CGPoint(x: tabBar.center.x, y: (circleView.frame.height / 2) * 1.05)
        
        let circleViewHeight = circleView.frame.size.height
        
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: circleViewHeight, height: circleViewHeight))
        button.setImage(UIImage(named: "temp_icon_red"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.center = CGPoint(x: circleViewHeight / 2, y: circleViewHeight / 2)
        button.addTarget(self, action: #selector(newEntryButtonAction), for: .touchUpInside)
        
        circleView.addSubview(button)
        tabBar.addSubview(circleView)
    }

    
    @objc func newEntryButtonAction() {
        
        let competitionEntryStoryboard = UIStoryboard(name: ENTRY, bundle: nil)
        let viewController = competitionEntryStoryboard.instantiateViewController(withIdentifier: SELECT_COMPETITION_MEDIA_VC)
        if let selectCompetitionMediaVC = viewController as? SelectCompetitionMediaVC {
            
            // Use full screen for capturing media.
            selectCompetitionMediaVC.videoGravity = .resizeAspectFill
            
            // Set max video duration to 60 seconds.
            selectCompetitionMediaVC.maximumVideoDuration = 60.0
            
            let navController = UINavigationController(rootViewController: selectCompetitionMediaVC)
            navController.isNavigationBarHidden = true
            present(navController, animated: true, completion: nil)
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

extension MainTBC: UITabBarControllerDelegate {
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        // The profile tab was selected.
//        if let navController = viewController as? UINavigationController, let profileVC = navController.children.first as? ProfileVC {
//
//            // Configure the ProfileVC for the current user.
//            profileVC.initData(userId: CurrentAccount.user.id)
//        }
    }
}
