//
//  KeyboardToolbar.swift
//  Versus
//
//  Created by JT Smrdel on 6/3/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class KeyboardToolbar: UIToolbar {

    init(frame: CGRect, includeNavigation: Bool) {
        super.init(frame: frame)
        
        barStyle = .default
        
        if includeNavigation {
            
            let previous = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(KeyboardToolbar.previousAction))
            previous.width = 50
            previous.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
            
            let next = UIBarButtonItem(image: UIImage(named: "right_icon"), style: .plain, target: self, action: #selector(KeyboardToolbar.nextAction))
            next.width = 50
            next.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
            
            let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(KeyboardToolbar.doneAction))
            done.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            
            items = [previous, next, flexSpace, done]
        }
        else {
            
            let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(KeyboardToolbar.doneAction))
            done.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            
            items = [flexSpace, done]
        }
        
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func previousAction() {
//        self.parentViewController
    }
    
    @objc func nextAction() {
//        self.parentViewController
    }
    
    @objc func doneAction() {
        self.parentViewController?.view.endEditing(true)
    }
}
