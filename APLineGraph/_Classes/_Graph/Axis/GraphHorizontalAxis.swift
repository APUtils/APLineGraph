//
//  GraphHorizontalAxis.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static let horizontalGap: CGFloat = 16
    
    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        dateFormatter.timeZone = .gmt
        
        return dateFormatter
    }()
}


extension Graph {
final class HorizontalAxis: Axis {
    
    // ******************************* MARK: - Types
    
    
    
    // ******************************* MARK: - Public Properties
    
    var dates: [Date] {
        didSet {
            guard oldValue != dates else { return }
            onDatesUpdate()
        }
    }
    
    var range: Graph.RelativeRange {
        didSet {
            guard oldValue != range else { return }
            update()
        }
    }
    
    // ******************************* MARK: - Private Properties
    
    private var labels: [UILabel] = []
    private var indexes: [CGFloat] = []
    private var activeLabels: [UILabel] = []
    
    private var lastIndex: CGFloat {
        return (dates.count - 1).asCGFloat
    }
    
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
        onDatesUpdate()
    }
    
    // ******************************* MARK: - Update
    
    private func onDatesUpdate() {
        queueAllLabels()
        labels = []
        indexes = []
        activeLabels = []
        attachSideLabels()
        update()
    }
    
    private func attachSideLabels() {
        guard let firstDate = dates.first, let lastDate = dates.last else { return }
        
        let leftLabelText = c.dateFormatter.string(from: firstDate)
        let leftLabel = addLabel(text: leftLabelText, center: .zero)
        leftLabel.frame.origin = .zero
        addPair(label: leftLabel, index: 0)
        
        let rightLabelText = c.dateFormatter.string(from: lastDate)
        let rightLabel = addLabel(text: rightLabelText, center: .zero)
        rightLabel.frame.origin = CGPoint(x: bounds.width - rightLabel.bounds.width, y: 0)
        addPair(label: rightLabel, index: lastIndex)
    }
    
    override func update() {
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
        let elementWidth = maxLabelSize.width + c.horizontalGap
        let halfElementWidth = elementWidth / 2
        let graphWidth = width / range.size
        let graphFrame = CGRect(x: -(graphWidth * range.from), y: 0, width: graphWidth, height: bounds.height)
        let visibleGraphFrame = CGRect(x: graphWidth * range.from, y: 0, width: graphWidth * range.size, height: bounds.height)
        let visibleLabelsFrame = visibleGraphFrame.insetBy(dx: -halfElementWidth, dy: 0)
        let dateStep = graphWidth / lastIndex
        let leftVisibleIndex = (visibleLabelsFrame.minX / dateStep).rounded(.down).clamped(min: 0, max: lastIndex)
        let rightVisibleIndex = (visibleLabelsFrame.maxX / dateStep).rounded(.up).clamped(min: 0, max: lastIndex)
        
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
                let newLabelCenter = leftLabel.center.middle(to: rightLabel.center)
                let newLabelIndex = (newLabelCenter.x - graphFrame.origin.x) / dateStep
                let newLabelDate = dates[newLabelIndex.asInt]
                let newLabelText = c.dateFormatter.string(from: newLabelDate)
                let newLabel = addLabel(text: newLabelText, center: newLabelCenter)
                setCenterX(label: newLabel, dateStep: dateStep, index: newLabelIndex, graphFrame: graphFrame)
                addPair(label: newLabel, index: newLabelIndex)
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
                removePair(label: label)
            }
        }
    }
    
    private func addPair(label: UILabel, index: CGFloat) {
        labels.append(label)
        indexes.append(index)
        activeLabels.append(label)
        
        label.alpha = 0
        UIView.animate(withDuration: Axis.animationDuration) {
            label.alpha = 1
        }
    }
    
    private func removePair(label: UILabel) {
        activeLabels.remove(label)
        
        label.alpha = 1
        UIView.animate(withDuration: Axis.animationDuration, animations: {
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
    
    // TODO: Optimize
    private func setCenterX(label: UILabel, dateStep: CGFloat, index: CGFloat, graphFrame: CGRect) {
        label.center.x = dateStep * index + graphFrame.origin.x
        label.frame.origin.x = min(label.frame.origin.x, graphFrame.maxX - label.bounds.width)
        label.frame.origin.x = max(label.frame.origin.x, graphFrame.origin.x)
    }
    
    private func getElementRect(label: UILabel, halfElementWidth: CGFloat, elementWidth: CGFloat) -> CGRect {
        return CGRect(x: label.center.x - halfElementWidth, y: 0, width: elementWidth, height: label.bounds.height)
    }
}
}
