//
//  Array+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

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

// ******************************* MARK: - Min & Max

extension Array where Element: Comparable {
    var minMax: (min: Element, max: Element) {
        var minimum = first!
        var maximum = minimum
        
        // if 'array' has an odd number of items, let 'minimum' or 'maximum' deal with the leftover
        var i = count % 2 // 1 if odd, skipping the first element
        while i < count {
            let left = self[i]
            let right = self[i+1]
            
            if left > right {
                if left > maximum {
                    maximum = left
                }
                if right < minimum {
                    minimum = right
                }
            } else {
                if right > maximum {
                    maximum = right
                }
                if left < minimum {
                    minimum = left
                }
            }
            
            i += 2
        }
        
        return (minimum, maximum)
    }
}

extension ArraySlice where Element: Comparable {
    var minMax: (min: Element, max: Element) {
        var minimum = first!
        var maximum = minimum
        
        // if 'array' has an odd number of items, let 'minimum' or 'maximum' deal with the leftover
        var i = startIndex + count % 2 // 1 if odd, skipping the first element
        while i < endIndex {
            let left = self[i]
            let right = self[i+1]
            
            if left > right {
                if left > maximum {
                    maximum = left
                }
                if right < minimum {
                    minimum = right
                }
            } else {
                if right > maximum {
                    maximum = right
                }
                if left < minimum {
                    minimum = left
                }
            }
            
            i += 2
        }
        
        return (minimum, maximum)
    }
}

extension Array where Element == CGFloat {
    func minMax(step: Int) -> (min: Element, max: Element) {
        var minimum = first!
        var maximum = minimum
        
        var i = step
        let maxI = count - step
        while i < maxI {
            let left = self[(i-step)...i].average
            let right = self[(i+1)...(i+step)].average
            
            if left > right {
                if left > maximum {
                    maximum = left
                }
                if right < minimum {
                    minimum = right
                }
            } else {
                if right > maximum {
                    maximum = right
                }
                if left < minimum {
                    minimum = left
                }
            }
            
            i += 2 * step
        }
        
        return (minimum, maximum)
    }
}

extension ArraySlice where Element == Graph.Plot.Point {
    func minMax(step: Int) -> (min: CGFloat, max: CGFloat) {
        var minimum = first!.value
        var maximum = minimum
        
        var i = startIndex + step
        let maxI = endIndex - step
        while i < maxI {
            let left = self[(i-step)...i].average
            let right = self[(i+1)...(i+step)].average
            
            if left > right {
                if left > maximum {
                    maximum = left
                }
                if right < minimum {
                    minimum = right
                }
            } else {
                if right > maximum {
                    maximum = right
                }
                if left < minimum {
                    minimum = left
                }
            }
            
            i += 2 * step
        }
        
        return (minimum, maximum)
    }
}

extension Array where Element == Graph.MinMaxRange {
    var minMax: (min: CGFloat, max: CGFloat) {
        var minimum = first!.min
        var maximum = first!.max
        
        var i = 1
        while i < count {
            let current = self[i]
            let min = current.min
            let max = current.max
            
            if max > maximum {
                maximum = max
            }
            
            if min < minimum {
                minimum = min
            }
            
            i += 1
        }
        
        return (minimum, maximum)
    }
}

extension ArraySlice where Element == Graph.MinMaxRange {
    var minMax: (min: CGFloat, max: CGFloat) {
        var minimum = first!.min
        var maximum = first!.max
        
        var i = startIndex + 1
        while i < endIndex {
            let current = self[i]
            let min = current.min
            let max = current.max
            
            if max > maximum {
                maximum = max
            }
            
            if min < minimum {
                minimum = min
            }
            
            i += 1
        }
        
        return (minimum, maximum)
    }
}

// ******************************* MARK: - Average

extension Array where Element == Graph.Plot.Point {
    var average: CGFloat {
        return reduce(0) { $0 + $1.value } / count.asCGFloat
    }
}

extension ArraySlice where Element == CGFloat {
    var average: CGFloat {
        return reduce(0, +) / count.asCGFloat
    }
}

extension ArraySlice where Element == Graph.Plot.Point {
    var average: CGFloat {
        return reduce(0) { $0 + $1.value } / count.asCGFloat
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
