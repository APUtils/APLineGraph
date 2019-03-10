//
//  Graph.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


public final class Graph: NSObject {
    
    // ******************************* MARK: - Public Properties
    
    public private(set) var plots: [Plot] = []
    
    public private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.contentInsetAdjustmentBehavior = .never
        
        return scrollView
    }()
    
    // ******************************* MARK: - Private Properties
    
    private var observer: NSKeyValueObservation!
    
    private var transformables: [Transformable] {
        return plots
    }
    
    // ******************************* MARK: - Initialization and Setup
    
    public override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        observer = scrollView.observe(\UIScrollView.bounds, options: [.old, .new]) { [weak self] scrollView, change in
            guard change.newValue != change.oldValue else { return }
            self?.configure()
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
    
    public func removeAllPlots() {
        plots.forEach(removePlot)
    }
    
    // ******************************* MARK: - Private Methods
    
    private func configure() {
        
        scrollView.contentSize = scrollView.bounds.size
        
        // TODO: Calculate transform depending on height, width and values
        
        guard let values = plots.first?.points else { return }
        
        let scaleX: CGFloat = scrollView.bounds.width / CGFloat(values.count)
//        let scaleY = bounds.height / CGFloat(values.compactMap { $0.value }.max()!)
        let scaleY: CGFloat = -1
        let transform = CGAffineTransform.identity
            .translatedBy(x: 0, y: scrollView.bounds.height)
            .scaledBy(x: scaleX, y: scaleY)
        
        let animated = UIView.isInAnimationClosure

        transformables.forEach { $0.setTransform(transform, animated: animated) }
    }
}
