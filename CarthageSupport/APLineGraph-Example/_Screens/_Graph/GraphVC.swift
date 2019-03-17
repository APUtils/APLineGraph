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
        graphContainer.backgroundColor = .clear
        graphContainer.addSubview(vm.mainGraph)
        vm.mainGraph.constraintSides(to: graphContainer)
        
        graphRangeContainer.backgroundColor = .clear
        graphRangeContainer.addSubview(vm.helperGraph)
        vm.helperGraph.constraintSides(to: graphRangeContainer)
    }
    
    private func setupRangeControl() {
        rangeControlView.configure(vm: RangeControlVM())
        rangeControlView.onRangeDidChange = { [weak self] range in
            self?.vm.mainGraph.showRange(range: range)
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
