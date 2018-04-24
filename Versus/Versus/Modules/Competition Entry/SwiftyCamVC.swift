//
//  SwiftyCamVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/24/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import SwiftyCam

class SwiftyCamVC: SwiftyCamViewController {

    @IBOutlet weak var cameraButton: SwiftyCamProgressButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.delegate = self
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
