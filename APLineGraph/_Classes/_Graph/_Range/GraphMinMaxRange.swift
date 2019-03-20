//
//  GraphMinMaxRange.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


public extension Graph {
public struct MinMaxRange {
    public let min: CGFloat
    public let max: CGFloat
    
    public init(min: CGFloat, max: CGFloat) {
        self.min = min
        self.max = max
    }
}
}

// ******************************* MARK: - Equatable

extension Graph.MinMaxRange: Equatable {}

// ******************************* MARK: - Computed Properties

public extension Graph.MinMaxRange {
    public static let zero = Graph.MinMaxRange(min: 0, max: 0)
    
    public var size: CGFloat {
        return max - min
    }
}

// ******************************* MARK: - CustomStringConvertible

extension Graph.MinMaxRange: CustomStringConvertible {
    public var description: String {
        return "(\(min), \(max))"
    }
}

