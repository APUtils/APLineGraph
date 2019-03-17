//
//  UIView+Style.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    @IBInspectable var isPrime: Bool {
        get {
            return false
        }
        set(isPrime) {
            if isPrime {
                AppearanceManager.shared.addPrimeView(self)
            } else {
                AppearanceManager.shared.addSecondaryView(self)
            }
        }
    }
    
    @IBInspectable var isSeparator: Bool {
        get {
            return false
        }
        set(isSeparator) {
            if isSeparator {
                AppearanceManager.shared.addSeparatorView(self)
            }
        }
    }
}

