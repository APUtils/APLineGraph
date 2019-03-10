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
    
    public private(set) var scale: CGPoint
    public private(set) var plots: [Plot] = []
    
    public private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        
        return scrollView
    }()
    
    // ******************************* MARK: - Private Properties
    
    private var scallables: [Scalable] {
        return plots
    }
    
    // ******************************* MARK: - Initialization and Setup
    
    public init() {
        self.scale = CGPoint(x: 1, y: 1)
    }
    
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
    
    private func configureContentSize() {
        // TODO:
    }
}

// ******************************* MARK: - Scalable

extension Graph: Scalable {
    public func setScale(_ scale: CGPoint, animated: Bool) {
        scallables.forEach { $0.setScale(scale, animated: animated) }
    }
}
