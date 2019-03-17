//
//  GraphPlotPoint.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


public extension Graph.Plot {
public struct Point {
    public let date: Date
    public let value: CGFloat
    
    public init(date: Date, value: CGFloat) {
        self.date = date
        self.value = value
    }
}
}

// ******************************* MARK: - Equatable

extension Graph.Plot.Point: Equatable {}
