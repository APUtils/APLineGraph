//
//  Graph.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static let verticalPercentGap: CGFloat = 0.1
}


public final class Graph: UIView {
    
    // ******************************* MARK: - Public Properties
    
    public var showAxises: Bool = false { didSet { updateAxises() } }
    public var lineWidth: CGFloat = 1 { didSet { updateLineLength() } }
    
    // ******************************* MARK: - Private Properties
    
    private var plotsShapeLayers: [Plot: CAShapeLayer] = [:]
    private var range: RelativeRange = .full
    private var horizontalAxis: HorizontalAxis?
    private var verticalAxis: VerticalAxis?
    
    // ******************************* MARK: - Initialization and Setup
    
    public init(showAxises: Bool, lineWidth: CGFloat) {
        self.showAxises = showAxises
        super.init(frame: UIScreen.main.bounds)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setupProperties()
        updateLineLength()
        updateAxises()
    }
    
    private func setupProperties() {
        backgroundColor = .white
        clipsToBounds = true
    }
    
    // ******************************* MARK: - Public Methods
    
    public func addPlot(_ plot: Plot) {
        addPlot(plot, updatePlots: true)
        updateAxises()
    }
    
    public func removePlot(_ plot: Plot) {
        removePlot(plot, updatePlots: true)
        updateAxises()
    }
    
    public func addPlots(_ plots: [Plot]) {
        plots.forEach { addPlot($0, updatePlots: false) }
        updatePlots()
        updateAxises()
    }
    
    public func removeAllPlots() {
        plotsShapeLayers.keys.forEach { removePlot($0, updatePlots: false) }
        updatePlots()
        updateAxises()
    }
    
    // TODO: Rethink this method so it convenient for anyone to use
    public func showRange(range: RelativeRange) {
        // TODO: if range size didn't change just scroll
        self.range = range
        horizontalAxis?.range = range
        verticalAxis?.range = range
        updatePlots()
    }
    
    // ******************************* MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        layoutAxises()
        updatePlots()
    }
    
    private func layoutAxises() {
        if let verticalAxis = verticalAxis {
            verticalAxis.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            sendSubviewToBack(verticalAxis)
        }
        
        if let horizontalAxis = horizontalAxis {
            let height = horizontalAxis.maxLabelSize.height
            horizontalAxis.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
            sendSubviewToBack(horizontalAxis)
        }
    }
    
    // ******************************* MARK: - Update
    
    private func updateAxises() {
        self.horizontalAxis?.removeFromSuperview()
        self.horizontalAxis = nil
        self.verticalAxis?.removeFromSuperview()
        self.verticalAxis = nil
        
        guard showAxises else { return }
        
        let dates = plotsShapeLayers
            .keys
            .flatMap { $0.points }
            .map { $0.date }
            .filterDuplicates()
            .sorted()
        
        let horizontalAxis = HorizontalAxis(dates: dates)
        self.horizontalAxis = horizontalAxis
        addSubview(horizontalAxis)
        
        let minMaxRanges = getMinMaxRanges()
        let verticalAxis = VerticalAxis(modes: .default, minMaxRanges: minMaxRanges, verticalPercentGap: c.verticalPercentGap)
        self.verticalAxis = verticalAxis
        addSubview(verticalAxis)
        
        layoutAxises()
    }
    
    private func updateLineLength() {
        plotsShapeLayers.values.forEach { $0.lineWidth = lineWidth }
    }
    
    private func updatePlots() {
        let width = bounds.width
        let height = bounds.height
        
        // Scale X
        let maxCount = plotsShapeLayers
            .keys
            .map { $0.valuesCount }
            .max() ?? 1
        
        let visibleRange = range.size
        let plotSize = CGFloat(maxCount)
        let scaleX: CGFloat = width / (plotSize * visibleRange)
        // TODO: This should be scroll not translation
        let translateX: CGFloat = -plotSize * range.from
        
        // Scale Y
        let minMaxRange = getMinMaxRange(range: range)
        let minValue: CGFloat = minMaxRange.min
        let maxValue: CGFloat = minMaxRange.max
        
        let rangeY: CGFloat = maxValue - minValue
        let gap: CGFloat = height * c.verticalPercentGap
        let availableHeight: CGFloat = height - 2 * gap
        
        // Scale to show range with top and bottom paddings
        let scaleY: CGFloat = availableHeight / rangeY
        // Move graph min value onto axis
        let translateY: CGFloat = -minValue
        
        let transform = CGAffineTransform.identity
            // Move axis origin to bottom of a screen plus gap
            .translatedBy(x: 0, y: height - gap)
            // Mirror over Y axis
            .scaledBy(x: 1, y: -1)
            // Scale graph by Y so it's in available range
            // Scale graph by X so it represents region length
            .scaledBy(x: scaleX, y: scaleY)
            // Apply X translation so graph on range start
            // Apply Y translation so graph is in available range
            .translatedBy(x: translateX, y: translateY)
        
        // Animate graph if changes are in animation closure
        let animated = UIView.isInAnimationClosure

        plotsShapeLayers.forEach { $0.0.configure(shapeLayer: $0.1, transform: transform, animated: animated) }
    }
    
    // ******************************* MARK: - Private Methods
    
    private func addPlot(_ plot: Plot, updatePlots: Bool) {
        let shapeLayer = plot.createShapeLayer()
        plotsShapeLayers[plot] = shapeLayer
        layer.addSublayer(shapeLayer)
        if updatePlots { self.updatePlots() }
    }
    
    private func removePlot(_ plot: Plot, updatePlots: Bool) {
        plotsShapeLayers[plot]?.removeFromSuperlayer()
        plotsShapeLayers[plot] = nil
        if updatePlots { self.updatePlots() }
    }
    
    private func getMinMaxRange(range: RelativeRange) -> MinMaxRange {
        let minMaxes = plotsShapeLayers
            .keys
            .map { $0.getMinMaxRange(range: range) }
        
        let minValue = minMaxes
            .map { $0.min }
            .min() ?? 0
        
        let maxValue = minMaxes
            .map { $0.max }
            .max() ?? 1
        
        return MinMaxRange(min: minValue, max: maxValue)
    }
    
    private func getMinMaxRanges() -> [MinMaxRange] {
        let count = plotsShapeLayers
            .keys
            .map { $0.points.count }
            .min() ?? 0
        
        var minMaxRanges: [MinMaxRange] = []
        for i in 0..<count {
            let values = plotsShapeLayers
                .keys
                .map { $0.points[i].value }
            
            let min = values.min() ?? 0
            let max = values.max() ?? 0
            let minMaxRange = MinMaxRange(min: min, max: max)
            minMaxRanges.append(minMaxRange)
        }
        
        return minMaxRanges
    }
}
