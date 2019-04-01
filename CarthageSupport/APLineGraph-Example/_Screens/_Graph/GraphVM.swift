//
//  GraphVM.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 4/1/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


struct GraphVM {
    private let graphModels: [GraphModel]? = DataSource().graphModels
    var graphVMs: [GraphViewVM]
    
    init() {
        graphVMs = graphModels?.map(GraphViewVM.init(graphModel:)) ?? []
    }
}
