//
//  Scalable.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit


public protocol Transformable: class {
    var transform: CGAffineTransform { get }
    func setTransform(_ transform: CGAffineTransform, animated: Bool)
}
