//
//  ValuesFormatterStyle.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


extension ValuesFormatter {
enum Style: Int, CaseIterable {
    case none = 1
    case kilo = 1000
    case million = 1000_000
    case billion = 1000_000_000
}
}

// ******************************* MARK: - Computed Properties

extension ValuesFormatter.Style {
    var divider: CGFloat {
        switch self {
        case .none: return 1
        case .kilo: return 1000
        case .million: return 1000_000
        case .billion: return 1000_000_000
        }
    }
    
    var shortcut: String {
        switch self {
        case .none: return ""
        case .kilo: return "k"
        case .million: return "m"
        case .billion: return "b"
        }
    }
}
