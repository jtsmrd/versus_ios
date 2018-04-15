//
//  FollowButton.swift
//  Versus
//
//  Created by JT Smrdel on 4/14/18.
//  Copyright © 2018 VersusTeam. All rights reserved.
//

import UIKit

class FollowButton: RoundButton {
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    func setButtonState(followStatus: FollowStatus) {
        DispatchQueue.main.async {
            switch followStatus {
            case .following:
                self.setTitle("following", for: .normal)
                self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                self.setTitleColor(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1), for: .normal)
                self._hasBorder = true
                self._borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                self._borderWidth = 1
            case .notFollowing:
                self.setTitle("follow", for: .normal)
                self.backgroundColor = #colorLiteral(red: 0, green: 0.7671272159, blue: 0.7075944543, alpha: 1)
                self.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
                self._hasBorder = false
            }
        }
    }
}
