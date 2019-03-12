//
//  GraphVC.swift
//  APLineGraph-Example
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


class GraphVC: UIViewController {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var graphContainer: UIView!
    @IBOutlet private weak var graphRangeContainer: UIView!
    @IBOutlet private weak var rangeControlView: RangeControlView!
    
    // ******************************* MARK: - Private Properties
    
    private let vm = GraphVM()
    
    // ******************************* MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        let mainScrollView = vm.mainGraph.scrollView
        graphContainer.addSubview(mainScrollView)
        mainScrollView.constraintSides(to: graphContainer)
        
        let helperScrollView = vm.helperGraph.scrollView
        helperScrollView.isUserInteractionEnabled = false
        graphRangeContainer.addSubview(helperScrollView)
        helperScrollView.constraintSides(to: graphRangeContainer)
        
        rangeControlView.onRangeDidChange = { [weak self] range in
            g.animate(2) {
                self?.vm.mainGraph.showRange(range: range)
            }
        }
    }
}
