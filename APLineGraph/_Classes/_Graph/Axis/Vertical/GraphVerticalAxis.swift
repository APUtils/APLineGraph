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
}


public extension Graph {
public final class VerticalAxis: Axis {
    
    // ******************************* MARK: - Public Properties
    
    var range: RelativeRange {
        didSet {
            guard oldValue != range else { return }
            update()
        }
    }
    
    var minMaxRanges: [MinMaxRange] {
        didSet {
            guard oldValue != minMaxRanges else { return }
            update()
        }
    }
    
    var configuration: Graph.Configuration {
        didSet {
            guard oldValue != configuration else { return }
            updateAppearance()
        }
    }
    
    // ******************************* MARK: - Private Properties
    
    private var elements: [GraphVerticalAxisElementView] = []
    private var values: [CGFloat] = []
    private var previousStep: CGFloat = 0
    private var previousValues: [CGFloat] = []
    private var previousGraphHeight: CGFloat?
    private var previousMinY: CGFloat?
    
    private lazy var elementsReuseController: ReuseController<GraphVerticalAxisElementView> = ReuseController<GraphVerticalAxisElementView>(create: { [weak self] in
        guard let self = self else { return GraphVerticalAxisElementView() }
        
        let view = GraphVerticalAxisElementView.create()
        view.bounds.size.width = self.bounds.width
        view.label.font = Axis.labelFont
        view.helperGuide.backgroundColor = self.configuration.helpLinesColor
        view.alpha = 0
        
        return view
    })
    
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
    
    init(minMaxRanges: [MinMaxRange], configuration: Graph.Configuration) {
        self.minMaxRanges = minMaxRanges
        self.configuration = configuration
        self.range = .full
        
        super.init(frame: UIScreen.main.bounds)
        
        setup()
    }
    
    private func setup() {
        isUserInteractionEnabled = false
    }
    
    // ******************************* MARK: - Update
    
    private func updateAppearance() {
        elementsReuseController.reusables.forEach { $0.helperGuide.backgroundColor = configuration.helpLinesColor }
    }
    
    override public func update() {
        // Need to bind container to specific value
        // If axis changes mode need to continue moving current containers and fade them out in the same time create new containers in a place where transformation started and animate then onto final position.
        // In a case mode stays the same - just move axises onto new position
        
        // First, need to add new labels add old positions
        // Second, need to change ALL existing elements positions
        
        // TODO: It's hard to read need to do something with it
        let height = bounds.height
        
        let maxIndex = minMaxRanges.count.asCGFloat - 1
        let minRangeIndex = (maxIndex * range.from).rounded().asInt
        let maxRangeIndex = (maxIndex * range.to).rounded().asInt
        let selectedMinMaxRanges = minMaxRanges[minRangeIndex...maxRangeIndex]
        var minY = selectedMinMaxRanges.map { $0.min }.min() ?? 0
        var maxY = selectedMinMaxRanges.map { $0.max }.max() ?? 0
        var graphHeight = maxY - minY
        
        // Adjust min and max to match bottom and top gap
        let additionalHeight = graphHeight / (1 - 2 * configuration.verticalPercentGap) - graphHeight
        minY -= additionalHeight / 2
        maxY += additionalHeight / 2
        graphHeight += additionalHeight
        
        let elementHeight = maxLabelSize.height + c.verticalGap
        let elementsCount = height / elementHeight
        let step = graphHeight / elementsCount
        
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
        
        let roundedStep = configuration.verticalAxisRegionDivideModes
            .map { $0.getRoundedStep(step: step) }
            .min() ?? step
        
        let initialValue = (minY / roundedStep).rounded(.up) * roundedStep
        
        let values = stride(from: initialValue, to: maxY, by: roundedStep).map { $0 }
        var formattedValues = ValuesFormatter.shared.strings(from: values)
        
        let isStepChanged = roundedStep != previousStep
        if isStepChanged && previousValues.hasElements {
            // TODO: Need to remove all current elements and add new one on proper position
            // Then animate to new position
            removeAbsent(newValues: values)
        }
        
        // TODO: Optimize
        
        // Dequeue flow
        let helperGuideHalfHeight: CGFloat = 0.5
        let elementHalfHeight: CGFloat = elementHeight / 2
        values.forEach { value in
            if let _ = self.values.firstIndex(of: value) { return }
            
            let element = elementsReuseController.dequeue()
            if let previousMinY = previousMinY, let previousGraphHeight = previousGraphHeight {
                // Move to previous position. Will be animated then from it.
                let centerY = height * (1 - (value - previousMinY) / previousGraphHeight) + helperGuideHalfHeight - elementHalfHeight
                let center = CGPoint(x: bounds.width / 2, y: centerY)
                element.center = center
                
                // Reset position animation because it should be animated from there.
                element.layer.removeAllAnimations()
                
            } else {
                // Initial setup. Just set current position.
                let centerY = height * (1 - (value - minY) / graphHeight) + helperGuideHalfHeight - elementHalfHeight
                let center = CGPoint(x: bounds.width / 2, y: centerY)
                element.center = center
            }
            
            // Set text
            if let textIndex = values.firstIndex(of: value) {
                element.label.text = formattedValues[textIndex]
            }
            
            addPair(element: element, value: value)
        }
        
        // Moving all elements to proper positions
        self.values.forEach { value in
            let centerY = height * (1 - (value - minY) / graphHeight) + helperGuideHalfHeight - elementHalfHeight
            let center = CGPoint(x: bounds.width / 2, y: centerY)
            
            guard let index = self.values.firstIndex(of: value) else { return }
            let element = elements[index]
            
            element.center = center
            
            if value < initialValue || value > maxY {
                // Remove elements that are moving out of screen
                removePair(element: element)
            }
            
            // Update text only if this value will stay
            if let textIndex = values.firstIndex(of: value) {
                element.label.text = formattedValues[textIndex]
            }
        }
        
        previousValues = values
        previousStep = roundedStep
        previousGraphHeight = graphHeight
        previousMinY = minY
    }
    
    private func addPair(element: GraphVerticalAxisElementView, value: CGFloat) {
        addSubview(element)
        elements.append(element)
        values.append(value)
        
        element.alpha = 0
        UIView.animate(withDuration: Axis.animationDuration) {
            element.alpha = 1
        }
    }
    
    private func removePair(element: GraphVerticalAxisElementView) {
        element.alpha = 1
        UIView.animate(withDuration: Axis.animationDuration, animations: {
            element.alpha = 0
        }, completion: { _ in
            guard let index = self.elements.firstIndex(of: element) else { return }
            self.elements.remove(at: index)
            self.values.remove(at: index)
            self.elementsReuseController.queue(element)
        })
    }
    
    private func removeAbsent(newValues: [CGFloat]) {
        values
            .filter { !newValues.contains($0) }
            .compactMap { values.firstIndex(of: $0) }
            .map { elements[$0] }
            .forEach(removePair(element:))
    }
}
}
