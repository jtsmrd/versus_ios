//
//  SwiftyCamVC.swift
//  Versus
//
//  Created by JT Smrdel on 4/24/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import SwiftyCam

class SwiftyCamVC: SwiftyCamViewController, CountdownTimerDelegate {

    @IBOutlet weak var cameraButton: SwiftyCamProgressButton!
    @IBOutlet weak var recordTimeRemainingLabel: UILabel!
    
    let MAX_TIME: Double = 60.0
    var countdownTimer: CountdownTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.delegate = self
    }
    
    @IBAction func switchCameraButtonAction() {
        switchCamera()
    }
    
    func startRecordingCountDown() {
        countdownTimer = CountdownTimer(countdownSeconds: MAX_TIME, delegate: self)
        countdownTimer.start()
        cameraButton.animateTimeRemaining()
    }
    
    func stopRecordingCountDown() {
        countdownTimer.stop()
        recordTimeRemainingLabel.text = "1:00"
        cameraButton.stopAnimatingTimeRemaining()
    }
    
    func timerTick(timeRemaining: Double) {
        recordTimeRemainingLabel.text = "0:\(Int(timeRemaining))"
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
