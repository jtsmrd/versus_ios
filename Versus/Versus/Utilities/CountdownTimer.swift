//
//  CountdownTimer.swift
//  Versus
//
//  Created by JT Smrdel on 4/27/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import Foundation

protocol CountdownTimerDelegate {
    func timerTick(timeRemaining: Int)
    func timerExpired()
}

class CountdownTimer {
    
    enum CountdownTimerType {
        case days
        case seconds
    }
    
    var timer: Timer!
    private var countdownTimerType: CountdownTimerType!
    private var countdownSeconds: Int
    private var delegate: CountdownTimerDelegate!
    
    init(countdownSeconds: Int, delegate: CountdownTimerDelegate) {
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
        
        countdownSeconds -= 1
        if countdownSeconds > 0 {
            delegate.timerTick(timeRemaining: self.countdownSeconds)
        }
        else {
            delegate.timerExpired()
            stop()
        }
    }
}
