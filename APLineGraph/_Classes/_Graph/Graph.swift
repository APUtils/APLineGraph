//
//  Graph.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


public final class Graph {
    
    // ******************************* MARK: - Public Properties
    
    public var scale: CGFloat = 1 { didSet { configureScale() } }
    public private(set) var plots: [Plot] = []
    
    public private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        
        return scrollView
    }()
    
    // ******************************* MARK: - Private Properties
    
    private var scallables: [Scalable] {
        return plots
    }
    
    // ******************************* MARK: - Initialization and Setup
    
    public init() {}
    
    // ******************************* MARK: - Public Methods
    
    public func addPlot(_ plot: Plot) {
        plots.append(plot)
        scrollView.layer.addSublayer(plot.shapeLayer)
        configureContentSize()
    }
    
    public func removePlot(_ plot: Plot) {
        plot.shapeLayer.removeFromSuperlayer()
        plots.remove(plot)
        configureContentSize()
    }
    
    // ******************************* MARK: - Private Methods
    
    private func configureScale() {
        scallables.forEach { $0.scale = scale }
    }
    
    private func configureContentSize() {
        // TODO:
    }
}

// ******************************* MARK: - Scalable

extension Graph: Scalable {}
