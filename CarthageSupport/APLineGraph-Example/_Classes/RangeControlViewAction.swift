//
//  RangeControlViewAction.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/12/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


extension RangeControlView {
    enum Action {
        case adjustLeft(left: CGFloat, width: CGFloat)
        case adjustRight(left: CGFloat, width: CGFloat)
        case move(left: CGFloat, width: CGFloat)
    }
}
