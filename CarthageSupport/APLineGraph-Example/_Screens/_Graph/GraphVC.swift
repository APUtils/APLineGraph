//
//  GraphVC.swift
//  APLineGraph-Example
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


class GraphVC: UIViewController {
    
    // ******************************* MARK: - Private Properties
    
    private let vm = GraphVM()
    
    // ******************************* MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        let scrollView = vm.graph.scrollView
        view.addSubview(scrollView)
        scrollView.constraintSides(to: view)
    }
}
