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
        
        let tabBarHeight = tabBar.frame.size.height
        
        let circleView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tabBarHeight * 1.2, height: tabBarHeight * 1.2))
        circleView.backgroundColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
        circleView.layer.cornerRadius = circleView.frame.height / 2
        circleView.clipsToBounds = true
        circleView.center = CGPoint(x: tabBar.center.x, y: tabBar.center.y - (tabBarHeight * 0.2))
        
        let circleViewHeight = circleView.frame.size.height
        
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: circleViewHeight * 0.7, height: circleViewHeight * 0.7))
        button.setImage(UIImage(named: "Add-Video"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.center =  CGPoint(x: tabBar.center.x, y: tabBar.center.y - (tabBarHeight * 0.2))
        button.addTarget(self, action: #selector(newCompetitionEntryButtonAction), for: .touchUpInside)
        
        view.addSubview(circleView)
        view.addSubview(button)
    }

    
    @objc func newCompetitionEntryButtonAction() {
        
        if let competitionEntryVC = UIStoryboard(name: "CompetitionEntry", bundle: nil).instantiateViewController(withIdentifier: COMPETITION_ENTRY_VC) as? CompetitionEntryVC {
            let navController = UINavigationController(rootViewController: competitionEntryVC)
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
