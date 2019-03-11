//
//  CGFloat+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/12/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


extension CGFloat {
    
    /// Computes and return clamped value within min and max bounds
    /// - parameter min: Minimum possible value.
    /// - parameter min: Maximum possible value.
    /// - returns: Clamped value.
    func clamped(min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.max(Swift.min(self, max), min)
    }
}
