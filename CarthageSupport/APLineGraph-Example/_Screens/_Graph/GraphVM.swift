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
    
    let graphModel: GraphModel
    let plots: [Graph.Plot]
    let mainGraph = Graph(showAxises: true, lineWidth: c.mainGraphLineWidth)
    let helperGraph = Graph(showAxises: false, lineWidth: c.helperGraphLineWidth)
    private(set) var plotSelectionVMs: [GraphPlotSelectionCellVM]
    
    // ******************************* MARK: - Private Properties
    
    // ******************************* MARK: - Initialization and Setup
    
    init(graphModel: GraphModel) {
        self.graphModel = graphModel
        
        let plots = graphModel
            .lines
            .compactMap { graphModel.getPlot(entry: $0) }
        
        self.plots = plots
        self.plotSelectionVMs = plots.map { GraphPlotSelectionCellVM(selected: true, plot: $0) }
        
        setup()
    }
    
    private func setup() {
        mainGraph.addPlots(plots)
        helperGraph.addPlots(plots)
        helperGraph.isUserInteractionEnabled = false
    }
    
    // ******************************* MARK: - Public Methods
    
    mutating func togglePlotSelection(index: Int) {
        plotSelectionVMs[index].selected.toggle()
        let plotSelectionVM = plotSelectionVMs[index]
        if plotSelectionVM.selected {
            mainGraph.addPlot(plotSelectionVM.plot)
            helperGraph.addPlot(plotSelectionVM.plot)
        } else {
            mainGraph.removePlot(plotSelectionVM.plot)
            helperGraph.removePlot(plotSelectionVM.plot)
        }
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
    
    func getPlot(entry: GraphEntry) -> Graph.Plot? {
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
        
        return Graph.Plot(name: name, lineColor: color, points: points)
    }
}
