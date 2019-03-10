//
//  GraphData.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


struct GraphData {
    let values: [GraphEntry: [Double]]
    let types: [GraphEntry: GraphEntryType]
    let names: [GraphEntry: String]
    let colors: [GraphEntry: UIColor]
}

// ******************************* MARK: - Decodable

extension GraphData: Decodable {
    
    enum Error: Swift.Error {
        case jsonConventionViolation
    }
    
    private enum CodingKeys: String, CodingKey {
        case columns
        case types
        case names
        case colors
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let columns = try container.decode([[ColumnEntry]].self, forKey: .columns)
        values = try columns.dictionaryMap { column in
            // First value should be GraphEntry
            guard let columnType = column.first?.graphEntry else { throw Error.jsonConventionViolation }
            
            // All other values should be values
            let values = try column.dropFirst().map { entry -> Double in
                guard let double = entry.double else { throw Error.jsonConventionViolation }
                return double
            }
            
            return (columnType, values)
        }
        
        let types = try container.decode([String: GraphEntryType].self, forKey: .types)
        self.types = try types.mapKeys { try GraphEntry(name: $0) }
        
        let names = try container.decode([String: String].self, forKey: .names)
        self.names = try names.mapKeys { try GraphEntry(name: $0) }
        
        let colors = try container.decode([String: String].self, forKey: .colors)
        let keyedColors = try colors.mapKeys { try GraphEntry(name: $0) }
        self.colors = keyedColors.compactMapValues { UIColor(hex: $0) }
    }
}
