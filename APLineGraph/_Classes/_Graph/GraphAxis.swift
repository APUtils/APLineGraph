//
//  GraphAxis.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


extension Constants {
    static let gap: CGFloat = 32
    static let fontSize: CGFloat = 10
    static let font: UIFont = UIFont.systemFont(ofSize: fontSize)
    static let textColor: UIColor = #colorLiteral(red: 0.5960784314, green: 0.6196078431, blue: 0.6392156863, alpha: 1)
    
    static var dateFormatter: DateFormatter = {
        let dateFromatter = DateFormatter()
        dateFromatter.dateFormat = "MMM d"
        dateFromatter.timeZone = .gmt
        
        return dateFromatter
    }()
}


public extension Graph {
public final class Axis: UIView {
    
    // ******************************* MARK: - Types
    
    public enum AxisType {
        case horizontal(dates: [Date])
        case vertical(values: [Double])
    }
    
    // ******************************* MARK: - Public Properties
    
    public let type: AxisType
    public var range: Graph.Range { didSet { update() } }
    
    public private(set) lazy var size: CGFloat = {
        switch type {
        case .horizontal: return maxLabelSize.height
        case .vertical(let values): return maxLabelSize.width
        }
    }()
    
    // ******************************* MARK: - Private Properties
    
    private lazy var pointsCount: CGFloat = {
        switch type {
        case .horizontal(dates: let dates): return dates.count.asCGFloat
        case .vertical(values: let values): return values.count.asCGFloat
        }
    }()
    
    private lazy var maxLabelSize: CGSize = {
        let height = c.font.lineHeight
        
        switch type {
        case .horizontal(let dates):
            let septemberDate = Date(timeIntervalSince1970: 1569082309)
            let width = c.dateFormatter.string(from: septemberDate).oneLineWidth(font: c.font)
            return CGSize(width: width, height: height)
            
        case .vertical(let values):
            let maxStringWidth = values.max()?.asString.oneLineWidth(font: c.font) ?? 0
            let minStringWidth = values.min()?.asString.oneLineWidth(font: c.font) ?? 0
            let width = max(maxStringWidth, minStringWidth)
            
            return CGSize(width: width, height: height)
        }
    }()
    
    // ******************************* MARK: - Initialization
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(type: AxisType) {
        self.type = type
        self.range = .full
        
        super.init(frame: UIScreen.main.bounds)
        
        setup()
    }
        
    private func setup() {
        update()
    }
    
    // ******************************* MARK: - Update
    
    private func update() {
        // TODO: Do better
        subviews
            .compactMap { $0 as? UILabel }
            .forEach {
                $0.removeFromSuperview()
                queueLabel(label: $0)
        }
        
        switch type {
        case .horizontal(let dates):
            let width = bounds.width
            let labelFullWidth = (maxLabelSize.width + c.gap)
            let widthDividedOnRangeSize = width / range.size
            let indexStepCGFloat = labelFullWidth / widthDividedOnRangeSize * pointsCount
            let indexStepInt = max(1, indexStepCGFloat.rounded().asInt)
            let initialIndex = indexStepCGFloat / 2
            var index = initialIndex.rounded().asInt
            let pointsCountInt = pointsCount.asInt
            while index < pointsCountInt {
                let date = dates[index]
                let label = dequeueLabel()
                label.font = c.font
                label.textColor = c.textColor
                label.text = c.dateFormatter.string(from: date)
                label.sizeToFit()
                label.center.x = widthDividedOnRangeSize * (index.asCGFloat / pointsCount - range.from)
                addSubview(label)
                
                index += indexStepInt
            }
            
            // TODO
        case .vertical: break
        }
    }
    
    // ******************************* MARK: - Reuse
    
    private var reusableLabels: [UILabel] = []
    
    private func dequeueLabel() -> UILabel {
        let label: UILabel
        if reusableLabels.hasElements {
            label = reusableLabels.removeFirst()
        } else {
            label = UILabel(frame: .zero)
            label.font = c.font
            label.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        }
        
        return label
    }
    
    private func queueLabel(label: UILabel) {
        reusableLabels.append(label)
    }
}
}
