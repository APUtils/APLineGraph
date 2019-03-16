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
    public let date: Date
    public let value: Double
    
    public init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}
}

// ******************************* MARK: - Computed Properties

extension Graph.Plot.Point {
    
}
