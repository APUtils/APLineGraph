//
//  GraphVerticalAxisRegionDivideMode.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


extension Graph.VerticalAxis {
enum RegionDivideMode: Int {
    case by2 = 2
    case by4 = 4
    case by5 = 5
    case by8 = 8
    case by10 = 10
    
    func getRoundedStep(step: CGFloat) -> CGFloat {
        let rawValueCGFloat = rawValue.asCGFloat
        let power: CGFloat
        switch self {
        case .by2:
            let _power = log2(step).rounded(.up)
            if _power.remainder(dividingBy: 2) == 0 {
                // Prevent powers of 4 and 8
                power = _power + 1
            } else {
                power = _power
            }
            
        case .by4:
            let _power = (log(step) / log(rawValueCGFloat)).rounded(.up)
            if _power.remainder(dividingBy: 3) == 0 {
                // Prevent powers of 8
                power = _power + 1
            } else {
                power = _power
            }
            
        case .by10: power = log10(step).rounded(.up)
        default: power = (log(step) / log(rawValueCGFloat)).rounded(.up)
        }
        
        return pow(rawValueCGFloat, power)
    }
}
}

// ******************************* MARK: - [RegionDivideMode]

extension Array where Element == Graph.VerticalAxis.RegionDivideMode {
    static let `default`: [Graph.VerticalAxis.RegionDivideMode] = [.by2, .by4, .by10]
}
