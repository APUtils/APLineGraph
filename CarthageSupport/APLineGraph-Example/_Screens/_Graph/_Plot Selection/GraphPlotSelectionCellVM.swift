//
//  GraphPlotSelectionCellVM.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit
import APLineGraph


struct GraphPlotSelectionCellVM {
    
    // ******************************* MARK: - Public Properties
    
    var selected: Bool
    let plot: Graph.Plot
    
    var color: UIColor {
        return plot.lineColor
    }
    
    var name: String {
        return plot.name
    }
    
    // ******************************* MARK: - Initialization and Setup
    
    init(selected: Bool, plot: Graph.Plot) {
        self.selected = selected
        self.plot = plot
    }
}
