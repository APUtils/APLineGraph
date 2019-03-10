//
//  ColumnEntry.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


/// Handles String and Double in the same array
enum ColumnEntry {
    case graphEntry(GraphEntry)
    case double(Double)
    
    var graphEntry: GraphEntry? {
        switch self {
        case .graphEntry(let graphEntry): return graphEntry
        default: return nil
        }
    }
    
    var double: Double? {
        switch self {
        case .double(let double): return double
        default: return nil
        }
    }
}

// ******************************* MARK: - Codable

extension ColumnEntry: Decodable {
    init(from decoder: Decoder) throws {
        do {
            self = .double(try decoder.singleValueContainer().decode(Double.self))
        } catch {
            // Try entry type now
            self = .graphEntry(try decoder.singleValueContainer().decode(GraphEntry.self))
        }
    }
}
