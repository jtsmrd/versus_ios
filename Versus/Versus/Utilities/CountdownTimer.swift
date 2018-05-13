//
//  CountdownTimer.swift
//  Versus
//
//  Created by JT Smrdel on 4/27/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

protocol CountdownTimerDelegate {
    func timerTick(timeRemaining: Double)
}

class CountdownTimer {
    
    enum CountdownTimerType {
        case days
        case seconds
    }
    
    var timer: Timer!
    private var countdownTimerType: CountdownTimerType!
    private var countdownSeconds: Double
    private var delegate: CountdownTimerDelegate!
    
    init(countdownSeconds: Double, delegate: CountdownTimerDelegate) {
        self.countdownSeconds = countdownSeconds
        self.delegate = delegate
    }
    
    func start() {
        
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(CountdownTimer.timerTick),
            userInfo: nil,
            repeats: true
        )
        timer.fire()
    }
    
    func stop() {
        timer.invalidate()
    }
    
    @objc func timerTick() {
        self.countdownSeconds -= 1.0
        self.delegate.timerTick(timeRemaining: self.countdownSeconds)
    }
}
