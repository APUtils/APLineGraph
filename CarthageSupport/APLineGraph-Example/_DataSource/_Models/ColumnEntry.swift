//
//  ColumnEntry.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


/// Handles String and Double in the same array
enum ColumnEntry {
    case graphEntry(GraphEntry)
    case value(CGFloat)
    
    var graphEntry: GraphEntry? {
        switch self {
        case .graphEntry(let graphEntry): return graphEntry
        default: return nil
        }
    }
    
    var date: Date? {
        switch self {
        case .value(let value): return Date(jsonDate: value.asTimeInterval)
        default: return nil
        }
    }
    
    var value: CGFloat? {
        switch self {
        case .value(let value): return value
        default: return nil
        }
    }
}

// ******************************* MARK: - Codable

extension ColumnEntry: Decodable {
    init(from decoder: Decoder) throws {
        do {
            // Try value
            let value = try decoder.singleValueContainer().decode(CGFloat.self)
            self = .value(value)
            
        } catch {
            // Try entry type
            self = .graphEntry(try decoder.singleValueContainer().decode(GraphEntry.self))
        }
    }
}
