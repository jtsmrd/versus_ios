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
    @IBOutlet weak var recordTimeRemainingLabel: UILabel!
    
    var seconds = 0
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.delegate = self
    }
    
    @IBAction func switchCameraButtonAction() {
        switchCamera()
    }
    
    func startRecordingCountDown() {
        seconds = 59
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(SwiftyCamVC.updateTimeRemainingLabel),
            userInfo: nil,
            repeats: true
        )
        recordTimeRemainingLabel.text = "0:\(seconds)"
    }
    
    func stopRecordingCountDown() {
        timer.invalidate()
    }
    
    func resetTimeRemainingLabel() {
        recordTimeRemainingLabel.text = "1:00"
    }
    
    @objc func updateTimeRemainingLabel() {
        seconds -= 1
        recordTimeRemainingLabel.text = "0:\(seconds)"
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
