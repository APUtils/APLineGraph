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


public final class Graph: NSObject {
    
    // ******************************* MARK: - Public Properties
    
    public private(set) var plots: [Plot] = []
    
    public private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        // TODO: Uncomment
//        scrollView.isScrollEnabled = false
        
        // TODO: Delete
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        
        return scrollView
    }()
    
    // ******************************* MARK: - Private Properties
    
    private var observer: NSKeyValueObservation!
    private var configuredSize: CGSize = .zero
    private var range: Range = .full
    
    private var transformables: [Transformable] {
        return plots
    }
    
    // ******************************* MARK: - Initialization and Setup
    
    public override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        observer = scrollView.observe(\UIScrollView.bounds, options: [.new]) { [weak self] scrollView, change in
            guard let self = self else { return }
            guard change.newValue?.size != self.configuredSize else { return }
            self.configure()
        }
        
        observer = scrollView.observe(\UIScrollView.frame, options: [.new]) { [weak self] scrollView, change in
            guard let self = self else { return }
            guard change.newValue?.size != self.configuredSize else { return }
            self.configure()
        }
    }
    
    // ******************************* MARK: - Public Methods
    
    public func addPlot(_ plot: Plot) {
        addPlot(plot, configure: true)
    }
    
    public func removePlot(_ plot: Plot) {
        removePlot(plot, configure: true)
    }
    
    public func addPlots(_ plots: [Plot]) {
        plots.forEach { addPlot($0, configure: false) }
        configure()
    }
    
    public func removeAllPlots() {
        plots.forEach { removePlot($0, configure: false) }
        configure()
    }
    
    // TODO: Rethink this method so it convenient for anyone to use
    public func showRange(range: Range) {
        self.range = range
        configure()
    }
    
    // ******************************* MARK: - Configuration
    
    private func configure() {
        // Update content size
        configuredSize = scrollView.bounds.size
        scrollView.contentSize = configuredSize
        
        // Scale X
        let maxCount = plots
            .map { $0.valuesCount }
            .max() ?? 1
        
        let visibleRange = range.size
        let plotSize = CGFloat(maxCount)
        let scaleX: CGFloat = scrollView.bounds.width / (plotSize * visibleRange)
        let translateX: CGFloat = plotSize * range.from
        
        // Scale Y
        let minValue = plots
            .compactMap { $0.minValue }
            .min()?
            .asCGFloat ?? 0
        
        let maxValue = plots
            .compactMap { $0.maxValue }
            .max()?
            .asCGFloat ?? 1
        
        let rangeY = maxValue - minValue
        let gap = scrollView.bounds.height * c.verticalPercentGap
        let availableHeight = scrollView.bounds.height - 2 * gap
        
        // Scale to show range with top and bottom paddings
        let scaleY: CGFloat = availableHeight / rangeY
        // Move graph min value onto axis
        let translateY: CGFloat = -minValue
        
        let transform = CGAffineTransform.identity
            // Move axis origin to bottom of a screen plus gap
            .translatedBy(x: 0, y: scrollView.bounds.height - gap)
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

        transformables.forEach { $0.setTransform(transform, animated: animated) }
    }
    
    // ******************************* MARK: - Private Methods
    
    private func addPlot(_ plot: Plot, configure: Bool) {
        plots.append(plot)
        scrollView.layer.addSublayer(plot.shapeLayer)
        if configure { self.configure() }
    }
    
    private func removePlot(_ plot: Plot, configure: Bool) {
        plot.shapeLayer.removeFromSuperlayer()
        plots.remove(plot)
        if configure { self.configure() }
    }
}
