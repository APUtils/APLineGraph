//
//  GraphVC.swift
//  APLineGraph-Example
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


final class GraphVC: UIViewController {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var graphContainer: UIView!
    @IBOutlet private weak var graphRangeContainer: UIView!
    @IBOutlet private weak var rangeControlView: RangeControlView!
    @IBOutlet private weak var plotsTableView: UITableView!
    @IBOutlet private weak var switchModeButton: UIButton!
    
    // ******************************* MARK: - Private Properties
    
    private var vm: GraphVM!
    
    // ******************************* MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        scrollView.contentInset.bottom = 36
        setupTableView()
        setupGraphs()
        setupRangeControl()
        updateButton()
    }
    
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
        
        vm.mainGraph.onStartTouching = { [weak self] in self?.scrollView.isScrollEnabled = false }
        vm.mainGraph.onStopTouching = { [weak self] in self?.scrollView.isScrollEnabled = true }
        
        // Helper
        graphRangeContainer.backgroundColor = .clear
        graphRangeContainer.addSubview(vm.helperGraph)
        vm.helperGraph.constraintSides(to: graphRangeContainer)
    }
    
    private func setupRangeControl() {
        rangeControlView.configure(vm: RangeControlVM())
        rangeControlView.onRangeDidChange = { [weak self] in self?.vm.mainGraph.showRange(range: $0) }
        
        rangeControlView.onStartTouching = { [weak self] in
            guard let self = self else { return }
            self.scrollView.isScrollEnabled = false
            g.animate { self.vm.mainGraph.autoScale = false }
        }
        
        rangeControlView.onStopTouching = { [weak self] in
            guard let self = self else { return }
            self.scrollView.isScrollEnabled = true
            g.animate { self.vm.mainGraph.autoScale = true }
        }
    }
    
    // ******************************* MARK: - Actions
    
    @IBAction private func onSwitchToNightModeTap(_ sender: UIButton) {
        AppearanceManager.shared.toggleStyle()
        updateButton()
    }
    
    // ******************************* MARK: - Update
    
    private func updateButton() {
        switch AppearanceManager.shared.style {
        case .day: switchModeButton.setTitle("Switch to Night Mode", for: .normal)
        case .night: switchModeButton.setTitle("Switch to Day Mode", for: .normal)
        }
    }
}

// ******************************* MARK: - InstantiatableFromStoryboard

extension GraphVC: InstantiatableFromStoryboard {
    static func create(vm: GraphVM) -> Self {
        let vc = create()
        vc.vm = vm
        return vc
    }
}

// ******************************* MARK: - UITableViewDelegate, UITableViewDataSource

extension GraphVC: UITableViewDelegate, UITableViewDataSource {
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
