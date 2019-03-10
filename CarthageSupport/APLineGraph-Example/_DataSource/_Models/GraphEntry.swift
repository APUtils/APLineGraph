//
//  GraphEntry.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


enum GraphEntry {
    case x
    case y(Int)
}

// ******************************* MARK: - Hashable

extension GraphEntry: Hashable {}

// ******************************* MARK: - RawRepresentable

extension GraphEntry: RawRepresentable {
    
    private static let xPrefix = "x"
    private static let yPrefix = "y"
    
    typealias RawValue = String
    
    var rawValue: String {
        switch self {
        case .x: return GraphEntry.xPrefix
        case .y(let number): return "\(GraphEntry.yPrefix)\(number)"
        }
    }
    
    init?(rawValue: String) {
        if rawValue == GraphEntry.xPrefix {
            self = .x
        } else if rawValue.hasPrefix(GraphEntry.yPrefix) {
            let numberString = rawValue.dropFirst(GraphEntry.yPrefix.count)
            if let number = Int(numberString) {
                self = .y(number)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

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

// ******************************* MARK: - Computed Properties

extension GraphEntry {
    var isY: Bool {
        switch self {
        case .y: return true
        default: return false
        }
    }
}
