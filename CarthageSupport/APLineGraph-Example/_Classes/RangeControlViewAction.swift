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
        case adjustLeft(left: CGFloat, width: CGFloat, touchStart: CGFloat)
        case adjustRight(left: CGFloat, width: CGFloat, touchStart: CGFloat)
        case move(left: CGFloat, width: CGFloat, touchStart: CGFloat)
    }
}

// ******************************* MARK: - Computed Properties

extension RangeControlView.Action {
    var touchStart: CGFloat {
        switch self {
        case .adjustLeft(_, _, let touchStart): return touchStart
        case .adjustRight(_, _, let touchStart): return touchStart
        case .move(_, _, let touchStart): return touchStart
        }
    }
}
