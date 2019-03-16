//
//  GraphVerticalAxis.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static let verticalGap: CGFloat = 8
}


extension Graph {
final class VerticalAxis: Axis {
    
    // ******************************* MARK: - Public Properties
    
    var range: RelativeRange { didSet { update() } }
    
    // ******************************* MARK: - Private Properties
    
    private let modes: [RegionDivideMode]
    private let minMaxRanges: [MinMaxRange]
    private let verticalPercentGap: CGFloat
    
    lazy var maxLabelSize: CGSize = {
        let height = Axis.labelFont.lineHeight
        let minValueStringWidth = minMaxRanges.map { $0.min }.min()?.asString.oneLineWidth(font: Axis.labelFont) ?? 0
        let maxValueStringWidth = minMaxRanges.map { $0.max }.max()?.asString.oneLineWidth(font: Axis.labelFont) ?? 0
        let width = Swift.max(minValueStringWidth, maxValueStringWidth)
        
        return CGSize(width: width, height: height)
    }()
    
    // ******************************* MARK: - Initialization and Setup
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(modes: [RegionDivideMode], minMaxRanges: [MinMaxRange], verticalPercentGap: CGFloat) {
        self.modes = modes
        self.minMaxRanges = minMaxRanges
        self.verticalPercentGap = verticalPercentGap
        self.range = .full
        
        super.init(frame: UIScreen.main.bounds)
    }
    
    // ******************************* MARK: - Axis Overrides
    
    override func update() {
        // TODO: Better reuse and only show labels that actually needed. Do not need to add labels outside of a screen.
        subviews
            .compactMap { $0 as? UILabel }
            .forEach {
                $0.removeFromSuperview()
                queueLabel(label: $0)
        }
        
        // TODO: It's hard to read need to do something with it
        let height = bounds.height
        
        let maxIndex = minMaxRanges.count.asCGFloat - 1
        let minRangeIndex = (maxIndex * range.from).rounded(.up).asInt
        let maxRangeIndex = (maxIndex * range.to).rounded(.down).asInt
        let selectedMinMaxRanges = minMaxRanges[minRangeIndex...maxRangeIndex]
        var min = selectedMinMaxRanges.map { $0.min }.min() ?? 0
        var max = selectedMinMaxRanges.map { $0.max }.max() ?? 0
        var size = max - min
        
        // Adjust min and max to match bottom and top gap
        let additionalSize = size / (1 - 2 * verticalPercentGap) - size
        min -= additionalSize / 2
        max += additionalSize / 2
        size += additionalSize
        
        let elementWidth = maxLabelSize.height + c.verticalGap
        let elementsCount = height / elementWidth
        let step = size / elementsCount
        
        // Choice divide mode with minimum step
        // Example:
        // min = 12
        // max = 278
        // elementsCount = 20.334
        // size = 266
        // step = 13.082
        
        // by2:
        // initialValue = 16
        // roundedStep = 16
        // values: [16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224, 240, 256]
        
        // by10:
        // initialValue = 100
        // roundedStep = 100
        // values: [100, 200]
        
        let roundedStep = modes
            .map { $0.getRoundedStep(step: step) }
            .min() ?? step
        
        let initialValue = (min / roundedStep).rounded(.up) * roundedStep
        var value = initialValue
        while value < max {
            let centerY = height * (1 - (value - min) / size)
            
            let label = dequeueLabel(text: value.asString)
            label.center.y = centerY
            addSubview(label)
            
            value += roundedStep
        }
    }
}
}
