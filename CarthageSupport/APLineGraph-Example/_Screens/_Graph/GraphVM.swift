//
//  GraphVM.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit

import APLineGraph


private extension Constants {
    static let mainGraphLineWidth: CGFloat = 2
    static let helperGraphLineWidth: CGFloat = 1
}


struct GraphVM {
    
    // ******************************* MARK: - Public Properties
    
    let mainGraph = Graph(showAxises: true)
    let helperGraph = Graph(showAxises: false)
    
    // ******************************* MARK: - Private Properties
    
    private let graphModels: [GraphModel]? = DataSource().graphModels
    
    // ******************************* MARK: - Initialization and Setup
    
    init() {
        setup()
    }
    
    private func setup() {
        guard let graphModels = graphModels else { return }
        
        // TODO: Add all other graphs
        guard let firstGraphModel = graphModels.first else { return }
        
        // TODO: Graphs reuse
        let mainPlots = firstGraphModel
            .lines
            .compactMap { firstGraphModel.getPlot(entry: $0, lineWidth: c.mainGraphLineWidth) }
        
        mainGraph.addPlots(mainPlots)
        
        let helperPlots = firstGraphModel
            .lines
            .compactMap { firstGraphModel.getPlot(entry: $0, lineWidth: c.helperGraphLineWidth) }
        
        helperGraph.addPlots(helperPlots)
    }
}

// ******************************* MARK: - Private Extensions

extension GraphModel {
    
    var xValues: [Date]? {
        guard let entryType = types[.x] else { print("X entry doesn't exist"); return nil }
        guard entryType == .x else { print("X entry type is wrong"); return nil }
        guard let values = self.values[.x] else { print("X values are missing"); return nil }
        let mapedValued = values.compactMap({ $0.date })
        guard values.count == mapedValued.count else { print("X values format is wrong"); return nil }
        
        return mapedValued
    }
    
    var lines: [GraphEntry] {
        return types
            .filter { $0.value == .line }
            .keys
            .map { $0 }
    }
    
    func getPlot(entry: GraphEntry, lineWidth: CGFloat) -> Graph.Plot? {
        guard let entryType = types[entry] else { print("Entry doesn't exist"); return nil }
        guard entryType == .line else { print("Plot works with `.line` type data only"); return nil }
        guard let values = self.values[entry] else { print("Values are missing"); return nil }
        let mapedValued = values.compactMap({ $0.value })
        guard values.count == mapedValued.count else { print("\(entry.rawValue) values format is wrong"); return nil }
        guard let name = self.names[entry] else { print("Name is missing"); return nil }
        guard let color = self.colors[entry] else { print("Color is missing"); return nil }
        guard let xValues = self.xValues else { return nil }
        guard xValues.count == mapedValued.count else { print("X values and \(entry.rawValue) values are in desync"); return nil }
        
        let points = zip(xValues, mapedValued).map { tuple in
            return Graph.Plot.Point(date: tuple.0, value: tuple.1)
        }
        
        return Graph.Plot(name: name, lineWidth: lineWidth, lineColor: color, points: points)
    }
}
