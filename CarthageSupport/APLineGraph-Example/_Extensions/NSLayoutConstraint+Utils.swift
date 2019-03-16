//
//  NSLayoutConstraint+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

// ******************************* MARK: - One Pixel Width

extension NSLayoutConstraint {
    /// Make one pixel size constraint
    @IBInspectable var onePixelSize: Bool {
        get {
            return constant == 1 / UIScreen.main.scale
        }
        set {
            constant = 1 / UIScreen.main.scale
        }
    }
}
