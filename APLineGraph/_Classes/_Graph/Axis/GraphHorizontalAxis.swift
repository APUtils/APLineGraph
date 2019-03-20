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
    
    private func setup() {
        isUserInteractionEnabled = false
    }
    
    // ******************************* MARK: - Update
    
    override func update() {
        // TODO: Better reuse and only show labels that actually needed. Do not need to add labels outside of a screen.
        // No need to remove labels if they just moved.
        queueAllLabels()
        
        let lastDatesIndexInt = dates.count - 1
        let lastDatesIndex = lastDatesIndexInt.asCGFloat
        let width = bounds.width
        let elementWidth = maxLabelSize.width + c.horizontalGap
        let graphSize = width / range.size
        let graphElementsCount = pow(2, log2(graphSize / elementWidth - 1).rounded(.down)) + 1
        let graphIdealStep = (graphSize - elementWidth) / (graphElementsCount - 1)
        let graphDateStep = graphSize / lastDatesIndex
        let graphVisibleAreaStart = graphSize * range.from
        let graphStartCenterX = (graphVisibleAreaStart - elementWidth / 2).fractionedUp(divider: graphIdealStep) + elementWidth / 2
        let graphVisibleAreaEnd = graphSize * range.to
        var graphCenterX = graphStartCenterX
        while graphCenterX <= graphVisibleAreaEnd {
            let index = (graphCenterX / graphDateStep).rounded().asInt
            guard index != 0 else { graphCenterX += graphIdealStep; continue }
            guard index != lastDatesIndexInt else { break }
            
            let date = dates[index]
            let text = c.dateFormatter.string(from: date)
            let realCenterX = (graphCenterX - graphSize * range.from)
            let center = CGPoint(x: realCenterX, y: maxLabelSize.height / 2)
            let label = addLabel(text: text, center: center)
            label.frame.origin.y = 0
            
            graphCenterX += graphIdealStep
        }
    }
}
}
