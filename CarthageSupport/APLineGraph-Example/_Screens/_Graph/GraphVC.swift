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
    
    // ******************************* MARK: - Private Properties
    
    private var vm: GraphVM!
    
    // ******************************* MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        let mainScrollView = vm.mainGraph
        graphContainer.addSubview(mainScrollView)
        mainScrollView.constraintSides(to: graphContainer)
        mainScrollView.isScrollEnabled = false
        
        let helperScrollView = vm.helperGraph
        helperScrollView.isUserInteractionEnabled = false
        graphRangeContainer.addSubview(helperScrollView)
        helperScrollView.constraintSides(to: graphRangeContainer)
        helperScrollView.isScrollEnabled = false
        
        rangeControlView.configure(vm: RangeControlVM())
        rangeControlView.onRangeDidChange = { [weak self] range in
            self?.vm.mainGraph.showRange(range: range)
        }
    }
    
    // ******************************* MARK: - Actions
    
    @IBAction private func onSwitchToNightModeTap(_ sender: Any) {
        // TODO:
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
