//
//  CGPoint+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/19/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


extension CGPoint {
    func simplifiedDistance(to point: CGPoint) -> CGFloat {
        let xDist = (point.x - x)
        let yDist = (point.y - y)
        return abs(xDist + yDist)
    }
    
    func middleX(to point: CGPoint) -> CGFloat {
        return (point.x + x) / 2
    }
}
