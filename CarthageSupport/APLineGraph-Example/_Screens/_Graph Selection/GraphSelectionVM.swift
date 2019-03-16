//
//  GraphSelectionVM.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


struct GraphSelectionVM {
    
    // ******************************* MARK: - Public Properties
    
    let cellVMs: [GraphSelectionCellVM]
    
    // ******************************* MARK: - Private Properties
    
    private let graphModels: [GraphModel]? = DataSource().graphModels
    
    // ******************************* MARK: - Initialization and Setup
    
    init() {
        self.cellVMs = graphModels?
            .enumerated()
            .map { GraphSelectionCellVM(text: "Graph #\($0)", graphModel: $1) } ?? []
    }
}
