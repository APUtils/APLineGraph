//
//  GraphVerticalAxisRegionDivideMode.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


public extension Graph.VerticalAxis {
public enum RegionDivideMode: Int {
    case by2 = 2
    case by4 = 4
    case by5 = 5
    case by8 = 8
    case by10 = 10
    
    func getRoundedStep(step: CGFloat) -> CGFloat {
        let roundedBy10Step = pow(10, log10(step).rounded(.up))
        let rawValueCGFloat = rawValue.asCGFloat
        
        switch self {
        case .by10:
            return roundedBy10Step
            
        default:
            let divided = roundedBy10Step / rawValueCGFloat
            if divided > step {
                return divided
            } else {
                return divided * 10
            }
        }
    }
}
}

// ******************************* MARK: - [RegionDivideMode]

extension Array where Element == Graph.VerticalAxis.RegionDivideMode {
    static let `default`: [Graph.VerticalAxis.RegionDivideMode] = [.by2, .by4, .by10]
}
