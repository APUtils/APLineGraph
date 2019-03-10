//
//  Plot.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit


public final class Plot {
    
    // ******************************* MARK: - Public Properties
    
    public private(set) lazy var shapeLayer: CAShapeLayer = CAShapeLayer()
    public let name: String
    public let points: [PlotPoint]
    public let lineWidth: CGFloat
    public let lineColor: UIColor
    public private(set) var scale: CGPoint
    
    // ******************************* MARK: - Private Properties
    
    private lazy var path: CGPath = {
        let path = CGMutablePath()
        
        // Start from first
        guard let firstPoint = points.first else { return path }
        
        let startPoint = CGPoint(x: 0, y: firstPoint.y)
        path.move(to: startPoint)
        
        // Add lines to other points
        for index in points.indices.dropFirst() {
            let point = points[index]
            let nextPointX = Double(index)
            let nextPointY = point.y
            let nextPoint = CGPoint(x: nextPointX, y: nextPointY)
            path.addLine(to: nextPoint)
        }
        
        return path.copy()!
    }()
    
    private var scaledPath: CGPath? {
        var transform = CGAffineTransform(scaleX: scale.x, y: scale.y)
        return path.copy(using: &transform)!
    }
    
    // ******************************* MARK: - Initialization and Setup
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(name: String, lineWidth: CGFloat, lineColor: UIColor, points: [PlotPoint]) {
        self.name = name
        self.points = points
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.scale = CGPoint(x: 1, y: 1)
        
        setup()
    }
    
    private func setup() {
        setupShapeLayer()
        configure(animated: false)
    }
    
    private func setupShapeLayer() {
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
    }
    
    // ******************************* MARK: - Configuration
    
    private func configure(animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = shapeLayer.path
            animation.duration = 0.3
            animation.timingFunction = .init(name: CAMediaTimingFunctionName.easeOut)
            animation.fillMode = .forwards
            
            shapeLayer.path = scaledPath
            shapeLayer.add(animation, forKey: animation.keyPath)
            
        } else {
            shapeLayer.path = scaledPath
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

extension Plot: Scalable {
    public func setScale(_ scale: CGPoint, animated: Bool) {
        self.scale = scale
        configure(animated: animated)
    }
}
