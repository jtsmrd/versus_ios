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
    
    let MAX_TIME: Int = 60
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
    
    func timerTick(timeRemaining: Int) {
//        recordTimeRemainingLabel.text = "0:\(Int(timeRemaining))"
        recordTimeRemainingLabel.text = String(format: "0:%02i", timeRemaining)
    }
    
    func timerExpired() {
        // Already handled by SwiftyCam time limit
    }
}
