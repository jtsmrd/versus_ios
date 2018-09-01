//
//  UIViewControllerExtensions.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import Toast_Swift

struct AssociatedKeys {
    static var activeFirstResponder: UIView = UIView()
}

extension UIViewController {
    
    
    /**
 
     */
    func displayError(error: CustomError) {
        view.makeToast(
            error.message,
            duration: 2.0,
            position: .top,
            title: nil,
            image: nil,
            style: .init(),
            completion: nil
        )
    }
    
    
    /**
     
     */
    func displayMessage(message: String) {
        view.makeToast(
            message,
            duration: 2.0,
            position: .top,
            title: nil,
            image: nil,
            style: .init(),
            completion: nil
        )
    }
    
    
    /**
     
     */
    var activeFirstResponder: UIView {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.activeFirstResponder) as? UIView else {
                return UIView()
            }
            return value
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.activeFirstResponder,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
