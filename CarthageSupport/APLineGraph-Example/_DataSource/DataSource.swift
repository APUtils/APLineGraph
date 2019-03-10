//
//  DataSource.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


private extension Constants {
    static let jsonName = "chart_data"
    static let jsonExtension = "json"
}


final class DataSource {
    
    // ******************************* MARK: - Public Properties
    
    let graphModels: [GraphModel]?
    
    // ******************************* MARK: - Initialization and Setup
    
    init() {
        guard let jsonURL = Bundle(for: DataSource.self).url(forResource: c.jsonName, withExtension: c.jsonExtension) else {
            print("Unable to get URL to plot data")
            self.graphModels = nil
            return
        }
        
        guard let data = Data(safeContentsOf: jsonURL) else {
            print("Unable to get plot data from file")
            self.graphModels = nil
            return
        }
        
        guard let graphData = JSONDecoder().safeDecode([GraphModel].self, from: data) else {
            print("Unable to decode plot data")
            self.graphModels = nil
            return
        }
        
        self.graphModels = graphData
    }
}
