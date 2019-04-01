//
//  Instantiatable.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

// ******************************* MARK: - InstantiatableFromXib

/// Helps to instantiate object from xib file.
protocol InstantiatableFromXib {
    static func create() -> Self
}

extension InstantiatableFromXib where Self: NSObject {
    static func objectFromXib<T>() -> T {
        return UINib(nibName: className, bundle: Bundle(for: self)).instantiate(withOwner: nil, options: nil).first as! T
    }
    
    /// Instantiates object from xib file.
    /// Xib filename should be equal to object class name.
    static func create() -> Self {
        return objectFromXib()
    }
}
