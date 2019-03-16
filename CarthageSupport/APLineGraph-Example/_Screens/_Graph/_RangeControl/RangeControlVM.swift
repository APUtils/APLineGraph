//
//  RangeControlVM.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/12/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import APLineGraph


struct RangeControlVM {
    
    // ******************************* MARK: - Public Properties
    
    let initialRange: Graph.RelativeRange
    
    // ******************************* MARK: - Initialization and Setup
    
    init() {
        initialRange = .full
    }
}
