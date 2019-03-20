//
//  CGFloat+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/12/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


extension CGFloat {
    
    var asDouble: Double {
        return Double(self)
    }
    
    var asInt: Int {
        return Int(self)
    }
    
    var asString: String {
        if truncatingRemainder(dividingBy: 1) != 0 {
            return "\(self)"
        } else {
            return "\(Int(rounded()))"
        }
    }
    
    /// Computes and return clamped value within min and max bounds
    /// - parameter min: Minimum possible value.
    /// - parameter min: Maximum possible value.
    /// - returns: Clamped value.
    func clamped(min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.max(Swift.min(self, max), min)
    }
    
    func fractionedUp(divider: CGFloat) -> CGFloat {
        return (self / divider).rounded(.up) * divider
    }
    
    func fractionedDown(divider: CGFloat) -> CGFloat {
        return (self / divider).rounded(.down) * divider
    }
}
