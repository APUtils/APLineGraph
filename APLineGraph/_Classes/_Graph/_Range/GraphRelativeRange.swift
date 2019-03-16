//
//  GraphRelativeRange.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/12/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


public extension Graph {
public struct RelativeRange {
    public let from: CGFloat
    public let to: CGFloat
    
    public init(from: CGFloat, to: CGFloat) {
        let from = from.clamped(min: 0, max: 1)
        self.from = from
        
        let to = to.clamped(min: from, max: 1)
        self.to = to
    }
}
}

// ******************************* MARK: - Computed Properties

public extension Graph.RelativeRange {
    public static var full: Graph.RelativeRange {
        return Graph.RelativeRange(from: 0, to: 1)
    }
    
    public var size: CGFloat {
        return to - from
    }
}

// ******************************* MARK: - CustomStringConvertible

extension Graph.RelativeRange: CustomStringConvertible {
    public var description: String {
        return "(\(from), \(to))"
    }
}
