//
//  Dictionary+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


// ******************************* MARK: - Scripting

extension Dictionary {
    /// Returns a new dictionary containing the keys of this dictionary with the
    /// values transformed by the given closure. Filters out keys with nil values.
    ///
    /// - Parameter transform: A closure that transforms a value. `transform`
    ///   accepts each value of the dictionary as its parameter and returns a
    ///   transformed value of the same or of a different type.
    /// - Returns: A dictionary containing the keys and transformed values of
    ///   this dictionary.
    func compactMapValues<T>(_ transform: (Dictionary.Value) throws -> T?) rethrows -> [Dictionary.Key: T] {
        var resultDictionary = [Dictionary.Key: T]()
        
        for (key, value) in self {
            guard let newValue = try transform(value) else { continue }
            
            resultDictionary[key] = newValue
        }
        
        return resultDictionary
    }
    
    /// Returns a new dictionary containing the values of this dictionary with the
    /// keys transformed by the given closure.
    ///
    /// - Parameter transform: A closure that transforms a key. `transform`
    ///   accepts each key of the dictionary as its parameter and returns a
    ///   transformed key of the same or of a different type.
    /// - Returns: A dictionary containing the transformed keys and values of
    ///   this dictionary.
    func mapKeys<T>(_ transform: (Dictionary.Key) throws -> T?) rethrows -> [T: Dictionary.Value] {
        var resultDictionary = [T: Dictionary.Value]()
        
        for (key, value) in self {
            guard let newKey = try transform(key) else { continue }
            resultDictionary[newKey] = value
        }
        
        return resultDictionary
    }
}
