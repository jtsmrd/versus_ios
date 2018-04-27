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
    
    func startTimer() {
        timer = Timer(timeInterval: countdownSeconds, repeats: true, block: { (t) in
            self.countdownSeconds -= 1.0
            self.delegate.timerTick(timeRemaining: self.countdownSeconds)
        })
    }
    
    func stopTimer() {
        timer.invalidate()
    }
}
