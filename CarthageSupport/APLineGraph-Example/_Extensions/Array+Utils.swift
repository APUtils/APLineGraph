//
//  Array+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


extension Array {
    /// Transforms an array to a dictionary using array elements as keys and transform result as values.
    func dictionaryMap<T: Hashable, U: Hashable>(_ transform: (_ element: Iterator.Element) throws -> (T, U)?) rethrows -> [T: U] {
        return try self.reduce(into: [T: U]()) { dictionary, element in
            guard let (key, value) = try transform(element) else { return }
            dictionary[key] = value
        }
    }
}
