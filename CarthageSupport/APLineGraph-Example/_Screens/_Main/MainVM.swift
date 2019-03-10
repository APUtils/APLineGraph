//
//  MainVM.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import APLineGraph


struct MainVM {
    
    // ******************************* MARK: - Public Properties
    
    let graph = Graph()
    
    // ******************************* MARK: - Private Properties
    
    private let dataSource = DataSource()
    
    // ******************************* MARK: - Initialization and Setup
    
    init() {
        print(dataSource)
    }
}
