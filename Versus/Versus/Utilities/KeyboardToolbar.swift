//
//  KeyboardToolbar.swift
//  Versus
//
//  Created by JT Smrdel on 6/3/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class KeyboardToolbar: UIToolbar {

    private let TOOLBAR_HEIGHT_SMALL: CGFloat = 40.0
    private let TOOLBAR_HEIGHT_MEDIUM: CGFloat = 45.0
    private let TOOLBAR_HEIGHT_LARGE: CGFloat = 50.0
    
    init(includeNavigation: Bool) {
        
        var toolbarHeight: CGFloat = 0.0
        
        switch UIDevice().deviceSizeType {
        case .small:
            toolbarHeight = TOOLBAR_HEIGHT_SMALL
        case .medium:
            toolbarHeight = TOOLBAR_HEIGHT_MEDIUM
        case .large:
            toolbarHeight = TOOLBAR_HEIGHT_LARGE
        case .unknown:
            toolbarHeight = TOOLBAR_HEIGHT_LARGE
        }
        
        let screenWidth = UIScreen.main.nativeBounds.width
        
        let toolbarFrame = CGRect(
            x: 0.0,
            y: 0.0,
            width: screenWidth,
            height: toolbarHeight
        )
        
        super.init(frame: toolbarFrame)
        
        barStyle = .default
        
        if includeNavigation {
            
            let previous = UIBarButtonItem(image: UIImage(named: "left_icon"), style: .plain, target: self, action: #selector(KeyboardToolbar.previousAction))
            previous.width = 50.0
            previous.tintColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
            
            let next = UIBarButtonItem(image: UIImage(named: "right_icon"), style: .plain, target: self, action: #selector(KeyboardToolbar.nextAction))
            next.width = 50.0
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
        
        if let firstResponderTag = parentViewController?.view.firstResponder?.tag {
            if let previousView = parentViewController?.view.viewWithTag(firstResponderTag - 100) {
                previousView.becomeFirstResponder()
            }
        }
    }
    
    @objc func nextAction() {
        
        if let firstResponderTag = parentViewController?.view.firstResponder?.tag {
            if let nextView = parentViewController?.view.viewWithTag(firstResponderTag + 100) {
                nextView.becomeFirstResponder()
            }
        }
    }
    
    @objc func doneAction() {
        parentViewController?.view.firstResponder?.resignFirstResponder()
    }
}
