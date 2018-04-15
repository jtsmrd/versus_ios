//
//  UIViewExtensions.swift
//  Versus
//
//  Created by JT Smrdel on 4/14/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

extension UIView {
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return (parentResponder as? UIViewController?)!
            }
        }
        return nil
    }
}
