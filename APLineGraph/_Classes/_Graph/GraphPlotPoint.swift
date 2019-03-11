//
//  GraphPlotPoint.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


public extension Graph.Plot {
public struct Point {
    public let x: String
    public let y: Double
    
    public init(x: String, y: Double) {
        self.x = x
        self.y = y
    }
}
}
