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
        let dateFromatter = DateFormatter()
        dateFromatter.dateFormat = "MMM d"
        dateFromatter.timeZone = .gmt
        
        return dateFromatter
    }()
}


extension Graph {
final class HorizontalAxis: Axis {
    
    // ******************************* MARK: - Public Properties
    
    var range: Graph.RelativeRange { didSet { update() } }
    
    // ******************************* MARK: - Private Properties
    
    private let dates: [Date]
    
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
    
    init(dates: [Date]) {
        self.dates = dates
        self.range = .full
        
        super.init(frame: UIScreen.main.bounds)
        
        setup()
    }
    
    private func setup() {
        isUserInteractionEnabled = false
    }
    
    // ******************************* MARK: - Update
    
    override func update() {
        // TODO: Better reuse and only show labels that actually needed. Do not need to add labels outside of a screen.
        subviews
            .compactMap { $0 as? UILabel }
            .forEach {
                $0.removeFromSuperview()
                queueLabel($0)
        }
        
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
            let label = dequeueLabel(text: text)
            label.center.x = centerX
            addSubview(label)
            
            index += indexStepInt
        }
    }
}
}
