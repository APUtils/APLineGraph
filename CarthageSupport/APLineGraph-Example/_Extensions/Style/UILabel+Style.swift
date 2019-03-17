//
//  UILabel+Style.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit


extension UILabel {
    @IBInspectable var isOnSecondary: Bool {
        get {
            return false
        }
        set(isOnSecondary) {
            if isOnSecondary {
                AppearanceManager.shared.addOnSecondaryLabel(self)
            } else {
                // On prime color isn't used
            }
        }
    }
}
