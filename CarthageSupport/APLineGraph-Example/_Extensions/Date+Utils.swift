//
//  Date+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation


extension Date {
    init(jsonDate: TimeInterval) {
        let timeIntervalSince1970 = jsonDate / 1000
        self.init(timeIntervalSince1970: timeIntervalSince1970)
    }
}
