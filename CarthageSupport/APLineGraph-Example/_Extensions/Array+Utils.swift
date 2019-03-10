//
//  Array+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


extension Array {
    /// Transforms an array into a dictionary.
    func dictionaryMap<T: Hashable, U>(_ transform: (_ element: Iterator.Element) throws -> (T, U)?) rethrows -> [T: U] {
        return try self.reduce(into: [T: U]()) { dictionary, element in
            guard let (key, value) = try transform(element) else { return }
            dictionary[key] = value
        }
    }
}
