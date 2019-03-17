//
//  Array+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation

// ******************************* MARK: - Scripting

extension Array {
    /// Helper method to filter out duplicates. Element will be filtered out if closure return true.
    func filterDuplicates(_ includeElement: (_ lhs: Element, _ rhs: Element) throws -> Bool) rethrows -> [Element] {
        var results = [Element]()
        
        try forEach { element in
            let existingElements = try results.filter {
                return try includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        
        return results
    }
    
    /// Transforms an array into a dictionary.
    func dictionaryMap<T: Hashable, U>(_ transform: (_ element: Iterator.Element) throws -> (T, U)?) rethrows -> [T: U] {
        return try self.reduce(into: [T: U]()) { dictionary, element in
            guard let (key, value) = try transform(element) else { return }
            dictionary[key] = value
        }
    }
}
// ******************************* MARK: - Equatable

extension Array where Element: Equatable {
    
    /// Helper method to filter out duplicates
    func filterDuplicates() -> [Element] {
        return filterDuplicates { $0 == $1 }
    }
    
    /// Helper method to remove all objects that are equal to passed one.
    mutating func remove(_ element: Element) {
        while let index = index(of: element) {
            remove(at: index)
        }
    }
}
