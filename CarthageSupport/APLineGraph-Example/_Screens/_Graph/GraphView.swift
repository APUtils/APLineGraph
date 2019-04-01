//
//  GraphView.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 4/1/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


final class GraphView: UIView {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var graphContainer: UIView!
    @IBOutlet private weak var graphRangeContainer: UIView!
    @IBOutlet private weak var rangeControlView: RangeControlView!
    @IBOutlet private weak var plotsTableView: UITableView!
    @IBOutlet private weak var switchModeButton: UIButton!
    
    // ******************************* MARK: - Private Properties
    
    private var vm: GraphViewVM!
    
    // ******************************* MARK: - Initialization and Setup
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        setupTableView()
        setupGraphs()
        setupRangeControl()
    }
    
    // ******************************* MARK: - Setup
    
    private func setupTableView() {
        plotsTableView.registerNib(class: GraphPlotSelectionCell.self)
        plotsTableView.estimatedRowHeight = 44
        plotsTableView.rowHeight = UITableView.automaticDimension
        plotsTableView.contentInset.bottom = -c.pixelSize
    }
    
    private func setupGraphs() {
        // Main
        graphContainer.backgroundColor = .clear
        graphContainer.addSubview(vm.mainGraph)
        vm.mainGraph.constraintSides(to: graphContainer)
        
        // Helper
        graphRangeContainer.backgroundColor = .clear
        graphRangeContainer.addSubview(vm.helperGraph)
        vm.helperGraph.constraintSides(to: graphRangeContainer)
    }
    
    private func setupRangeControl() {
        rangeControlView.configure(vm: RangeControlVM())
        rangeControlView.onRangeDidChange = { [weak self] range in
            self?.vm.mainGraph.showRange(range: range, animated: true)
        }
        
        // Uncomment to change animation behavior
//        rangeControlView.onStartTouching = { [weak self] in
//            guard let self = self else { return }
//            g.animate { self.vm.mainGraph.autoScale = false }
//        }
//
//        rangeControlView.onStopTouching = { [weak self] in
//            guard let self = self else { return }
//            g.animate { self.vm.mainGraph.autoScale = true }
//        }
    }
}

// ******************************* MARK: - InstantiatableFromXib

extension GraphView: InstantiatableFromXib {
    static func create(vm: GraphViewVM) -> Self {
        let view = create()
        view.vm = vm
        view.setup()
        
        return view
    }
}

// ******************************* MARK: - UITableViewDelegate, UITableViewDataSource

extension GraphView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.plotSelectionVMs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellVM = vm.plotSelectionVMs[indexPath.row]
        let cell: GraphPlotSelectionCell = tableView.dequeue(for: indexPath)
        cell.configure(vm: cellVM)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        vm.togglePlotSelection(index: indexPath.row)
        guard let cell = tableView.cellForRow(at: indexPath) as? GraphPlotSelectionCell else { return }
        cell.configure(vm: vm.plotSelectionVMs[indexPath.row])
    }
}
