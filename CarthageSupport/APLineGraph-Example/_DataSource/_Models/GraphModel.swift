//
//  GraphModel.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


struct GraphModel {
    let values: [GraphEntry: [ColumnEntry]]
    let types: [GraphEntry: GraphEntryType]
    let names: [GraphEntry: String]
    let colors: [GraphEntry: UIColor]
}

// ******************************* MARK: - Decodable

extension GraphModel: Decodable {
    
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
        self.values = try columns.dictionaryMap { column in
            // First value should be GraphEntry
            guard let columnType = column.first?.graphEntry else { throw Error.jsonConventionViolation }
            let datesOrValues = Array(column.dropFirst())
            return (columnType, datesOrValues)
        }
        
        // Check that date counts are synchronized
        let datesCounts = values.map({ $1.count })
        guard let firstDatesCount = datesCounts.first else { throw Error.jsonConventionViolation }
        let areDatesCountsEqual = datesCounts
            .dropFirst()
            .map { $0 == firstDatesCount }
            .reduce(true) { $0 && $1 }
        
        guard areDatesCountsEqual else { throw Error.jsonConventionViolation }
        
        // Impossible to directly use something except String or Int as dictionary key
        // https://forums.swift.org/t/rfc-can-this-codable-bug-still-be-fixed/18501/3
        let types = try container.decode([String: GraphEntryType].self, forKey: .types)
        self.types = try types.mapKeys { try GraphEntry(name: $0) }
        
        let names = try container.decode([String: String].self, forKey: .names)
        self.names = try names.mapKeys { try GraphEntry(name: $0) }
        
        let colors = try container.decode([String: String].self, forKey: .colors)
        let keyedColors = try colors.mapKeys { try GraphEntry(name: $0) }
        self.colors = keyedColors.compactMapValues { UIColor(hex: $0) }
    }
}
