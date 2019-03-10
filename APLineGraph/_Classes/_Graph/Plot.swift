//
//  Plot.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


public final class Plot {
    
    // ******************************* MARK: - Public Properties
    
    public private(set) lazy var shapeLayer: CAShapeLayer = CAShapeLayer()
    public var scale: CGFloat = 1 { didSet { shapeLayer.setNeedsDisplay() } }
    public var points: [PlotPoint] { didSet { shapeLayer.setNeedsDisplay() } }
    public var lineWidth: CGFloat { didSet { shapeLayer.setNeedsDisplay() } }
    public var lineColor: UIColor { didSet { shapeLayer.setNeedsDisplay() } }
    
    // ******************************* MARK: - Initialization and Setup
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(lineWidth: CGFloat, lineColor: UIColor, points: [PlotPoint]) {
        self.points = points
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        
        setup()
    }
    
    private func setup() {
        guard let firstPoint = points.first else { return }
        
        // Start from first
        let path = CGMutablePath()
        let startPoint = CGPoint(x: 0, y: firstPoint.y)
        path.move(to: startPoint)
        
        // Add lines to other points
        for index in points.indices.dropFirst() {
            // TODO: Check that index is 1
            let point = points[index]
            let nextPointX = CGFloat(index)
            let nextPointY = point.y
            let nextPoint = CGPoint(x: nextPointX, y: nextPointY)
            path.addLine(to: nextPoint)
        }
    }
}

// ******************************* MARK: - Equatable

extension Plot: Equatable {
    public static func == (lhs: Plot, rhs: Plot) -> Bool {
        return lhs === rhs
    }
}

// ******************************* MARK: - Scalable

extension Plot: Scalable {}
