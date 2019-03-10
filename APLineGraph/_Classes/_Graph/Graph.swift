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
        scrollView.isScrollEnabled = false
        
        return scrollView
    }()
    
    // ******************************* MARK: - Private Properties
    
    private var observer: NSKeyValueObservation!
    private var configuredSize: CGSize = .zero
    
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
        plots.append(plot)
        scrollView.layer.addSublayer(plot.shapeLayer)
        configure()
    }
    
    public func removePlot(_ plot: Plot) {
        plot.shapeLayer.removeFromSuperlayer()
        plots.remove(plot)
        configure()
    }
    
    public func addPlots(_ plots: [Plot]) {
        plots.forEach {
            self.plots.append($0)
            scrollView.layer.addSublayer($0.shapeLayer)
        }
        
        configure()
    }
    
    public func removeAllPlots() {
        plots.forEach {
            $0.shapeLayer.removeFromSuperlayer()
            plots.remove($0)
        }
        
        configure()
    }
    
    // ******************************* MARK: - Private Methods
    
    private func configure() {
        // Update content size
        configuredSize = scrollView.bounds.size
        scrollView.contentSize = configuredSize
        
        // Scale X
        let maxCount = plots
            .map { $0.valuesCount }
            .max() ?? 1
        
        let scaleX: CGFloat = scrollView.bounds.width / CGFloat(maxCount)
        
        // Scale Y
        let minValue = plots
            .compactMap { $0.minValue }
            .min()?
            .asCGFloat ?? 0
        
        let maxValue = plots
            .compactMap { $0.maxValue }
            .max()?
            .asCGFloat ?? 1
        
        let range = maxValue - minValue
        let gap = scrollView.bounds.height * c.verticalPercentGap
        let availableHeight = scrollView.bounds.height - 2 * gap
        
        // Scale to show range with top and bottom paddings
        // and mirror graph so Y axis goes from bottom
        let scaleY: CGFloat = -(availableHeight / range)
        
        let transform = CGAffineTransform.identity
            // Move axis origin to bottom of a screen plus gap
            .translatedBy(x: 0, y: scrollView.bounds.height - gap)
            // Scale graph do it's in available range and mirrored
            .scaledBy(x: scaleX, y: scaleY)
            // Move graph min value onto axis
            .translatedBy(x: 0, y: -minValue)
        
        // Animate graph if changes are in animation closure
        let animated = UIView.isInAnimationClosure

        transformables.forEach { $0.setTransform(transform, animated: animated) }
    }
}
