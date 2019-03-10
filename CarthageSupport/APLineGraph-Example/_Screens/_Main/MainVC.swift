//
//  MainVC.swift
//  APLineGraph-Example
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


class MainVC: UIViewController {
    
    // ******************************* MARK: - Private Properties
    
    private let vm = MainVM()
    
    // ******************************* MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        vm.graph.scrollView
    }
}

