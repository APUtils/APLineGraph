//
//  UIView+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/11/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

// ******************************* MARK: - Animations

extension UIView {
    /// Checks if code runs inside animation closure
    static var isInAnimationClosure: Bool {
        return inheritedAnimationDuration > 0
    }
}

// ******************************* MARK: - Corner Radius

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
