//
//  ValuesFormatter.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


final class ValuesFormatter {
    
    // ******************************* MARK: - Singleton
    
    static let shared = ValuesFormatter()
    
    // ******************************* MARK: - Initialization and Setup
    
    // ******************************* MARK: - Internal Methods
    
    func strings(from values: [CGFloat]) -> [String] {
        let style = Style
            .allCases
            .sorted { $0.rawValue > $1.rawValue }
            .first { areValues(values, suitableFor: $0) } ?? .none
        
        return apply(style: style, values: values)
    }
    
    // ******************************* MARK: - Private Methods
    
    private func areValues(_ values: [CGFloat], suitableFor style: Style) -> Bool {
        return values.reduce(true) { $0 && $1.truncatingRemainder(dividingBy: style.divider / 100) == 0 }
    }
    
    // TODO: Write compact
    private func apply(style: Style, values: [CGFloat]) -> [String] {
        let dividedValues = values.map { $0 / style.divider }
        let isAllCeil = values.reduce(true) { $0 && $1.truncatingRemainder(dividingBy: style.divider) == 0 }
        
        if isAllCeil {
            return dividedValues.map {
                if $0 == 0 {
                    return "0"
                } else {
                    return "\($0.asString)\(style.shortcut)"
                }
            }
        } else {
            let isAllDivideBy10 = values.reduce(true) { $0 && $1.truncatingRemainder(dividingBy: style.divider / 10) == 0 }
            if isAllDivideBy10 {
                return dividedValues.map {
                    if $0 == 0 {
                        return "0"
                    } else {
                        return String(format: "%.1f%@", $0, style.shortcut)
                    }
                }
            } else {
                return dividedValues.map {
                    if $0 == 0 {
                        return "0"
                    } else {
                        return String(format: "%.2f%@", $0, style.shortcut)
                    }
                }
            }
        }
    }
}
