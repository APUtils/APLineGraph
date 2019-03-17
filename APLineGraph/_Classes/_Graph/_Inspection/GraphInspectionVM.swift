//
//  GraphInspectionVM.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter
    }()
    
    static let yearFormatter: DateFormatter = {
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        return yearFormatter
    }()
}


struct GraphInspectionVM {
    
    // ******************************* MARK: - Types
    
    struct Value {
        let value: String
        let color: UIColor
    }
    
    // ******************************* MARK: - Internal Properties
    
    let date: String
    let year: String
    let values: [Value]
    
    // ******************************* MARK: - Initialization and Setup
    
    init(date: Date, plotsPoints: [Graph.Plot: Graph.Plot.Point]) {
        self.date = c.dateFormatter.string(from: date)
        self.year = c.yearFormatter.string(from: date)
        self.values = plotsPoints.map { Value(value: $0.1.value.asString, color: $0.0.lineColor) }
    }
}
