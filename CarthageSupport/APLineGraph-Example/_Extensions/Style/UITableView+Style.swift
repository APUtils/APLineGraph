//
//  UITableView+Style.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit


extension UITableView {
    @IBInspectable var stylizeSeparators: Bool {
        get {
            return false
        }
        set(stylizeSeparators) {
            if stylizeSeparators {
                // Doesn't work without async
                DispatchQueue.main.async {
                    AppearanceManager.shared.addSeparatorsTableView(self)
                }
            }
        }
    }
}
