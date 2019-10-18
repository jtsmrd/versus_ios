//
//  AsyncOperation.swift
//  Versus
//
//  Created by JT Smrdel on 3/30/19.
//  Copyright © 2019 VersusTeam. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    
    
    var _isFinished: Bool = false
    var _isExecuting: Bool = false
    
    
    override var isAsynchronous: Bool {
        return true
    }
    
    
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
        
        get {
            return _isFinished
        }
    }
    
    
    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
        
        get {
            return _isExecuting
        }
    }
    
    
    override func start() {
        isExecuting = true
        execute()
        isExecuting = false
        isFinished = true
    }
    
    
    func execute() {
        
    }
}
