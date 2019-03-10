//
//  GraphEntryType.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


enum GraphEntryType: String {
    case line
    case x
}

// ******************************* MARK: - Decodable

extension GraphEntryType: Decodable {
    
    enum Error: Swift.Error {
        case typeConventionViolation
    }
    
    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        if let entryType = GraphEntryType(rawValue: rawValue) {
            self = entryType
        } else {
            throw Error.typeConventionViolation
        }
    }
}
