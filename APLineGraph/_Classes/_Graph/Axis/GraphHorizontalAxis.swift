//
//  GraphHorizontalAxis.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        dateFormatter.timeZone = .gmt
        
        return dateFormatter
    }()
}


extension Graph {
final class HorizontalAxis: UIView {
    
    // ******************************* MARK: - Public Properties
    
    var dates: [Date] {
        didSet {
            guard oldValue != dates else { return }
            onDatesUpdate(animated: true)
        }
    }
    
    var range: Graph.RelativeRange {
        didSet {
            guard oldValue != range else { return }
            update(animated: true)
        }
    }
    
    // ******************************* MARK: - Private Properties
    
    private var configuration: Graph.Configuration
    private var labels: [UILabel] = []
    private var indexes: [CGFloat] = []
    private var activeLabels: [UILabel] = []
    private var previousSize: CGSize = .zero
    
    private var lastIndex: CGFloat {
        return (dates.count - 1).asCGFloat
    }
    
    private var horizontalGap: CGFloat {
        return configuration.axisLabelFont.pointSize * 1.5
    }
    
    private lazy var labelsReuseController: ReuseController<UILabel> = ReuseController<UILabel>(create: { [weak self] in
        guard let self = self else { return UILabel() }
        
        let label = UILabel(frame: CGRect(origin: .zero, size: self.maxLabelSize))
        label.font = self.configuration.axisLabelFont
        label.textColor = self.configuration.axisLabelColor
        label.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        label.alpha = 0
        label.lineBreakMode = .byClipping
        
        return label
    })
    
    private(set) lazy var maxLabelSize: CGSize = {
        let height = configuration.axisLabelFont.lineHeight
        // May 22
        let septemberDate = Date(timeIntervalSince1970: 1558542309)
        let width = c.dateFormatter.string(from: septemberDate).oneLineWidth(font: configuration.axisLabelFont)
        return CGSize(width: width, height: height)
    }()
    
    // ******************************* MARK: - Initialization and Setup
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(dates: [Date], configuration: Graph.Configuration) {
        self.dates = dates
        self.configuration = configuration
        self.range = .full
        
        super.init(frame: UIScreen.main.bounds)
        
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        onDatesUpdate(animated: false)
    }
    
    // ******************************* MARK: - UIView Methods Overrides
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard previousSize != bounds.size else { return }
        previousSize = bounds.size
        update(animated: false)
    }
    
    // ******************************* MARK: - Update
    
    private func onDatesUpdate(animated: Bool) {
        queueAllLabels()
        labels = []
        indexes = []
        activeLabels = []
        attachSideLabels(animated: animated)
        update(animated: animated)
    }
    
    private func attachSideLabels(animated: Bool) {
        guard let firstDate = dates.first, let lastDate = dates.last else { return }
        
        let leftLabelText = c.dateFormatter.string(from: firstDate)
        let leftLabel = addLabel(text: leftLabelText, centerX: 0)
        leftLabel.frame.origin = .zero
        addPair(label: leftLabel, index: 0, animated: animated)
        
        let rightLabelText = c.dateFormatter.string(from: lastDate)
        let rightLabel = addLabel(text: rightLabelText, centerX: 0)
        rightLabel.frame.origin = CGPoint(x: bounds.width - rightLabel.bounds.width, y: 0)
        addPair(label: rightLabel, index: lastIndex, animated: animated)
    }
    
    func update(animated: Bool) {
        // Labels should bind to specific dates
        // There should be array of labels which we check from back and remove collided labels
        // Side labels are special. They are binded to side dates but not centered under them. Instead they just glue to graph sides.
        // First we layout existing labels so they are aligned to dates.
        // Second we check if we can add new label. Check is follow:
        // We sort labels by centerX and then if distance between centers of near labels more than 2 * elemnetWidth then we attach label to a closest date and centering it. If it collides it will be removed on next step.
        // Third we check array of labels from back and remove collided.
        // This way those that were added later will be removed first so we'll always have base labels added and removing happens inverse to adding.
        // Need to also do it aminated. Animate label alpha and remove label on completion and put it in reuse pool.
        // Labels text never changed after binding. We actually bind to index of date not a date itself. And index we need to just calculate label position.
        
        let lastIndex = self.lastIndex
        let width = bounds.width
        let elementWidth = maxLabelSize.width + horizontalGap
        let halfElementWidth = elementWidth / 2
        let graphWidth = width / range.size
        let graphFrame = CGRect(x: -(graphWidth * range.from), y: 0, width: graphWidth, height: bounds.height)
        let visibleGraphFrame = CGRect(x: graphWidth * range.from, y: 0, width: graphWidth * range.size, height: bounds.height)
        let visibleLabelsFrame = visibleGraphFrame.insetBy(dx: -halfElementWidth, dy: 0)
        let dateStep = graphWidth / lastIndex
        
        let additionalIndex = visibleLabelsFrame.size.width / dateStep
        let leftVisibleIndex = (visibleLabelsFrame.minX / dateStep - additionalIndex).rounded(.down).clamped(min: 0, max: lastIndex)
        let rightVisibleIndex = (visibleLabelsFrame.maxX / dateStep + additionalIndex).rounded(.up).clamped(min: 0, max: lastIndex)
        
        // Layout
        zip(labels, indexes)
            .forEach {
                if $0.1 >= leftVisibleIndex && $0.1 <= rightVisibleIndex {
                    $0.0.isHidden = false
                    setCenterX(label: $0.0, dateStep: dateStep, index: $0.1, graphFrame: graphFrame)
                } else {
                    $0.0.isHidden = true
                }
        }
        
        // Add labels if possible
        var positionSortedLabels: [UILabel] = []
        var wasAdded = true
        
        while wasAdded {
            wasAdded = false
            
            positionSortedLabels = activeLabels
                .filter { !$0.isHidden }
                .sorted { $0.center.x < $1.center.x }
            
            for (index, rightLabel) in positionSortedLabels.enumerated().dropFirst() {
                let leftLabel = positionSortedLabels[index - 1]
                let distance = rightLabel.center.x - leftLabel.center.x
                guard distance >= 2 * elementWidth else { continue }
                guard let leftLabelIndex = getIndex(label: leftLabel) else { continue }
                guard let rightLabelIndex = getIndex(label: rightLabel) else { continue }
                guard rightLabelIndex - leftLabelIndex > 1 else { continue }
                let newLabelCenterX = leftLabel.center.middleX(to: rightLabel.center)
                let newLabelIndex = (newLabelCenterX - graphFrame.origin.x) / dateStep
                let newLabelDate = dates[newLabelIndex.rounded().asInt]
                let newLabelText = c.dateFormatter.string(from: newLabelDate)
                let newLabel = addLabel(text: newLabelText, centerX: newLabelCenterX)
                setCenterX(label: newLabel, dateStep: dateStep, index: newLabelIndex, graphFrame: graphFrame)
                addPair(label: newLabel, index: newLabelIndex, animated: animated)
                wasAdded = true
            }
        }
        
        let labelsToCheck = activeLabels
            .dropFirst()
            .dropFirst()
            .filter { !$0.isHidden }
            .reversed()
        
        let positionSortedLabelsLastIndex = positionSortedLabels.count - 1
        
        // Remove collided
        for label in labelsToCheck {
            guard let sortedLabelsIndex = positionSortedLabels.firstIndex(of: label) else { continue }
            
            guard sortedLabelsIndex - 1 >= 0 else { continue }
            let leftLabel = positionSortedLabels[sortedLabelsIndex - 1]
            guard activeLabels.firstIndex(of: leftLabel) != nil else { continue }
            let leftLabelRect = getElementRect(label: leftLabel, halfElementWidth: halfElementWidth, elementWidth: elementWidth)
            
            guard sortedLabelsIndex + 1 <= positionSortedLabelsLastIndex else { continue }
            let rightLabel = positionSortedLabels[sortedLabelsIndex + 1]
            guard activeLabels.firstIndex(of: rightLabel) != nil else { continue }
            let rightLabelRect = getElementRect(label: rightLabel, halfElementWidth: halfElementWidth, elementWidth: elementWidth)
            
            let labelRect = getElementRect(label: label, halfElementWidth: halfElementWidth, elementWidth: elementWidth)
            if labelRect.intersects(leftLabelRect) || labelRect.intersects(rightLabelRect) {
                removePair(label: label, animated: animated)
            }
        }
    }
    
    private func addPair(label: UILabel, index: CGFloat, animated: Bool) {
        labels.append(label)
        indexes.append(index)
        activeLabels.append(label)
        
        label.alpha = 0
        g.animateIfNeeded(animated ? configuration.animationDuration : 0) {
            label.alpha = 1
        }
    }
    
    private func removePair(label: UILabel, animated: Bool) {
        activeLabels.remove(label)
        
        label.alpha = 1
        g.animateIfNeeded(animated ? configuration.animationDuration : 0, animations: {
            label.alpha = 0
        }, completion: { _ in
            guard let index = self.labels.firstIndex(of: label) else { return }
            self.labels.remove(at: index)
            self.indexes.remove(at: index)
            self.queueLabel(label)
        })
    }
    
    private func getIndex(label: UILabel) -> CGFloat? {
        guard let index = activeLabels.firstIndex(of: label) else { return nil }
        return indexes[index]
    }
    
    private func setCenterX(label: UILabel, dateStep: CGFloat, index: CGFloat, graphFrame: CGRect) {
        var originX = dateStep * index + graphFrame.origin.x - label.bounds.width / 2
        originX = originX.clamped(min: graphFrame.origin.x, max: graphFrame.maxX - label.bounds.width)
        
        label.frame.origin.x = originX
    }
    
    private func getElementRect(label: UILabel, halfElementWidth: CGFloat, elementWidth: CGFloat) -> CGRect {
        return CGRect(x: label.center.x - halfElementWidth, y: 0, width: elementWidth, height: label.bounds.height)
    }
    
    // ******************************* MARK: - Reuse
    
    private func addLabel(text: String, centerX: CGFloat) -> UILabel {
        let label = labelsReuseController.dequeue()
        label.text = text
        label.alpha = 1
        label.center.x = centerX
        addSubview(label)
        
        return label
    }
    
    private func queueLabel(_ label: UILabel) {
        labelsReuseController.queue(label)
    }
    
    private func queueAllLabels() {
        labelsReuseController.queueAll()
    }
}
}
