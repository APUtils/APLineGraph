//
//  AppearanceManagerStyle.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit


extension AppearanceManager {
enum Style {
    case day
    case night
}
}

// ******************************* MARK: - Computed Properties

extension AppearanceManager.Style {
    var primaryColor: UIColor {
        switch self {
        case .day: return #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        case .night: return #colorLiteral(red: 0.09411764706, green: 0.1333333333, blue: 0.1764705882, alpha: 1)
        }
    }
    
    var secondaryColor: UIColor {
        switch self {
        case .day: return #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1)
        case .night: return #colorLiteral(red: 0.1294117647, green: 0.1843137255, blue: 0.2470588235, alpha: 1)
        }
    }
    
    var onSecondaryColor: UIColor {
        switch self {
        case .day: return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .night: return #colorLiteral(red: 0.9960784314, green: 0.9960784314, blue: 0.9960784314, alpha: 1)
        }
    }
    
    var separatorColor: UIColor {
        switch self {
        case .day: return #colorLiteral(red: 0.8117647059, green: 0.8196078431, blue: 0.8235294118, alpha: 1)
        case .night: return #colorLiteral(red: 0.07058823529, green: 0.1019607843, blue: 0.137254902, alpha: 1)
        }
    }
    
    var statusBarStyle: UIStatusBarStyle {
        switch self {
        case .day: return .default
        case .night: return .lightContent
        }
    }
}
