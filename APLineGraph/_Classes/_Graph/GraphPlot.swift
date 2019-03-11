//
//  GraphPlot.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit


private extension Constants {
    static let defaultAnimationDuration: TimeInterval = 0.3
}


// TODO:
// Plot should be a struct with just actual plot description.
// Need to move out `shapeLayer`, leave `path` and rename `scalablePath`
// into `computePath(transform:)` or something like that.
// Idea here is to reuse path calculation so one plot can be used on two graphs but with different transforms.
// Maybe also make creation async so it can happen on BG thread.
public extension Graph {
public final class Plot {
    
    // ******************************* MARK: - Public Properties
    
    public private(set) lazy var shapeLayer: CAShapeLayer = CAShapeLayer()
    public let name: String
    public let points: [Point]
    public let lineWidth: CGFloat
    public let lineColor: UIColor
    public private(set) var transform: CGAffineTransform
    
    // ******************************* MARK: - Internal Properties
    
    var valuesCount: Int {
        return points.count
    }
    
    var minValue: Double {
        return points
            .map { $0.y }
            .min() ?? 0
    }
    
    var maxValue: Double {
        return points
            .map { $0.y }
            .max() ?? 1
    }
    
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
        var transform = self.transform
        return path.copy(using: &transform)
    }
    
    // ******************************* MARK: - Initialization and Setup
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init?(name: String, lineWidth: CGFloat, lineColor: UIColor, points: [Point]) {
        guard points.hasElements else { return nil }
        
        self.name = name
        self.points = points
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.transform = .identity
        
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
        shapeLayer.lineJoin = .round
    }
    
    // ******************************* MARK: - Internal Methods
    
    func getMinMaxValue(range: Graph.Range) -> (Double, Double) {
        let startIndex = (valuesCount.asDouble * range.from.asDouble).rounded().asInt
        let endIndex = (valuesCount.asDouble * range.to.asDouble).rounded().asInt
        let subpoints = points[startIndex..<endIndex]
        let subvalues = subpoints.map { $0.y }
        let minValue = subvalues.min() ?? 0
        let maxValue = subvalues.max() ?? 1
        return (minValue, maxValue)
    }
    
    // ******************************* MARK: - Configuration
    
    private func configure(animated: Bool) {
        if animated {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = shapeLayer.path
            pathAnimation.duration = UIView.inheritedAnimationDuration > 0 ? UIView.inheritedAnimationDuration : c.defaultAnimationDuration
            pathAnimation.timingFunction = .init(name: CAMediaTimingFunctionName.easeOut)
            pathAnimation.fillMode = .forwards
            shapeLayer.path = scaledPath
            shapeLayer.add(pathAnimation, forKey: pathAnimation.keyPath)
            
        } else {
            shapeLayer.path = scaledPath
        }
    }
}
}

// ******************************* MARK: - Equatable

extension Graph.Plot: Equatable {
    public static func == (lhs: Graph.Plot, rhs: Graph.Plot) -> Bool {
        return lhs === rhs
    }
}

// ******************************* MARK: - Transformable

extension Graph.Plot: Transformable {
    public func setTransform(_ transform: CGAffineTransform, animated: Bool) {
        self.transform = transform
        
        // TODO: Remove later
        // Should be:
        // MinX: 56.799999999999955
        // MinY: 511.19999999999993
        print("MinX: \(scaledPath!.boundingBox.minY), MinY: \(scaledPath!.boundingBox.maxY)")
        
        configure(animated: animated)
    }
}
