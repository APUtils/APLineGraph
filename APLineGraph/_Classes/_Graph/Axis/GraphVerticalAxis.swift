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
    static let distanceToHelperView: CGFloat = 2
    static let helperViewBackgroundColor: UIColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
}


extension Graph {
final class VerticalAxis: Axis {
    
    // ******************************* MARK: - Public Properties
    
    var range: RelativeRange { didSet { update() } }
    
    // ******************************* MARK: - Private Properties
    
    private let modes: [RegionDivideMode]
    private let minMaxRanges: [MinMaxRange]
    private let verticalPercentGap: CGFloat
    
    private lazy var maxLabelSize: CGSize = {
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
        
        setup()
    }
    
    private func setup() {
        isUserInteractionEnabled = false
    }
    
    // ******************************* MARK: - Axis Overrides
    
    override func update() {
        // TODO: Better reuse and only show labels that actually needed. Do not need to add labels outside of a screen.
        subviews
            .compactMap { $0 as? UILabel }
            .forEach {
                $0.removeFromSuperview()
                queueLabel($0)
        }
        
        subviews
            .forEach {
                $0.removeFromSuperview()
                queueHelperView($0)
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
        
        let elementHeight = maxLabelSize.height + c.verticalGap
        let elementsCount = height / elementHeight
        let step = size / elementsCount
        
        // Choice divide mode with minimum step
        // Example:
        // min = 12
        // max = 278
        // elementsCount = 20.334
        // size = 266
        // step = 13.082
        
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
            label.center.y = centerY - maxLabelSize.height / 2 - c.distanceToHelperView
            addSubview(label)
            
            let view = dequeueHelperView()
            view.center.y = centerY
            addSubview(view)
            
            value += roundedStep
        }
    }
    
    // ******************************* MARK: - Reuse
    
    private var reusableHelperViews: [UIView] = []
    
    private func dequeueHelperView() -> UIView {
        let view: UIView
        if reusableHelperViews.hasElements {
            view = reusableHelperViews.removeFirst()
        } else {
            let frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1)
            view = UIView(frame: frame)
            view.backgroundColor = c.helperViewBackgroundColor
            view.autoresizingMask = [.flexibleWidth]
        }
        
        return view
    }
    
    private func queueHelperView(_ view: UIView) {
        reusableHelperViews.append(view)
    }
}
}
