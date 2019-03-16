//
//  GraphSelectionCellVM.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


struct GraphSelectionCellVM {
    
    // ******************************* MARK: - Public Properties
    
    let text: String
    let graphModel: GraphModel
    
    // ******************************* MARK: - Initialization and Setup
    
    init(text: String, graphModel: GraphModel) {
        self.text = text
        self.graphModel = graphModel
    }
}
