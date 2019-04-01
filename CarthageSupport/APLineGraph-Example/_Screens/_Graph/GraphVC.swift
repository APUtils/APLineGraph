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
    @IBOutlet private weak var graphsContainer: UIStackView!
    @IBOutlet private weak var switchModeButton: UIButton!
    
    // ******************************* MARK: - Private Properties
    
    private var vm = GraphVM()
    
    // ******************************* MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        scrollView.contentInset.bottom = 36
        scrollView.panGestureRecognizer.cancelsTouchesInView = false
        setupGraphs()
        updateButton()
    }
    
    private func setupGraphs() {
        let views = vm.graphVMs.map(GraphView.create(vm:))
        views.forEach(graphsContainer.addArrangedSubview)
    }
    
    // ******************************* MARK: - Actions
    
    @IBAction private func onSwitchToNightModeTap(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            AppearanceManager.shared.toggleStyle()
        }
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
