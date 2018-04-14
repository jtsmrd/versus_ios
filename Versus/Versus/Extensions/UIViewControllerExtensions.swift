//
//  UIViewControllerExtensions.swift
//  Versus
//
//  Created by JT Smrdel on 4/13/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit
import Toast_Swift

extension UIViewController {
    
    func displayError(error: CustomError) {
        view.makeToast(
            error.desc,
            duration: 2.0,
            position: .top,
            title: nil,
            image: nil,
            style: .init(),
            completion: nil
        )
    }
    
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
}
