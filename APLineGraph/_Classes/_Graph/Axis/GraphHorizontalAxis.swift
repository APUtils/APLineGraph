//
//  GraphHorizontalAxis.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static let horizontalGap: CGFloat = 32
    
    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        dateFormatter.timeZone = .gmt
        
        return dateFormatter
    }()
}


extension Graph {
final class HorizontalAxis: Axis {
    
    // ******************************* MARK: - Public Properties
    
    var dates: [Date] { didSet { update() } }
    var range: Graph.RelativeRange { didSet { update() } }
    
    // ******************************* MARK: - Private Properties
    
    private(set) lazy var maxLabelSize: CGSize = {
        let height = Axis.labelFont.lineHeight
        let septemberDate = Date(timeIntervalSince1970: 1569082309)
        let width = c.dateFormatter.string(from: septemberDate).oneLineWidth(font: Axis.labelFont)
        return CGSize(width: width, height: height)
    }()
    
    // ******************************* MARK: - Initialization and Setup
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(dates: [Date], configuration: Graph.Configuration) {
        self.dates = dates
        self.range = .full
        
        super.init(frame: UIScreen.main.bounds)
        
        setup()
    }
    
    required init(configuration: Graph.Configuration) {
        fatalError("init(configuration:) has not been implemented")
    }
    
    private func setup() {
        isUserInteractionEnabled = false
    }
    
    // ******************************* MARK: - Update
    
    override func update() {
        // TODO: Better reuse and only show labels that actually needed. Do not need to add labels outside of a screen.
        // No need to remove labels if they just moved.
        queueAllLabels()
        
        // TODO: It's hard to read need to do something with it
        // TODO: Need to use 2 divider
        let pointsCount = dates.count.asCGFloat
        let width = bounds.width
        let elementWidth = maxLabelSize.width + c.horizontalGap
        let widthDividedOnRangeSize = width / range.size
        let indexStepCGFloat = elementWidth / widthDividedOnRangeSize * pointsCount
        let indexStepInt = max(1, indexStepCGFloat.rounded().asInt)
        let initialIndex = indexStepCGFloat / 2
        var index = initialIndex.rounded().asInt
        let pointsCountInt = pointsCount.asInt
        while index < pointsCountInt {
            let date = dates[index]
            let text = c.dateFormatter.string(from: date)
            let centerX = widthDividedOnRangeSize * (index.asCGFloat / pointsCount - range.from)
            let center = CGPoint(x: centerX, y: maxLabelSize.height / 2)
            let label = addLabel(text: text, center: center)
            label.frame.origin.y = 0
            
            index += indexStepInt
        }
    }
}
}
