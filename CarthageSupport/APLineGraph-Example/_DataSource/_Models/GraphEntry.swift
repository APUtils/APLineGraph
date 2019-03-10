//
//  GraphEntry.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


enum GraphEntry: String {
    case x
    case y0
    case y1
    case y2
    case y3
    case y4
    case y5
}

// ******************************* MARK: - Hashable

extension GraphEntry: Hashable {}

// ******************************* MARK: - Decodable

extension GraphEntry: Decodable {
    
    enum Error: Swift.Error {
        case jsonConventionViolation
    }
    
    init(from decoder: Decoder) throws {
        let name = try decoder.singleValueContainer().decode(String.self)
        self = try GraphEntry(name: name)
    }
    
    init(name: String) throws {
        if let graphEntry = GraphEntry(rawValue: name) {
            self = graphEntry
        } else {
            throw Error.jsonConventionViolation
        }
    }
}
