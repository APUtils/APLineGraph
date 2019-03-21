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


public extension Graph {
public struct Plot {
    
    // ******************************* MARK: - Public Properties
    
    /// Plots considered equal if they have the same name.
    public let name: String
    public let points: [Point]
    public var lineColor: UIColor
    
    // ******************************* MARK: - Internal Properties
    
    let lastIndex: CGFloat
    let minValue: CGFloat
    let maxValue: CGFloat
    
    // ******************************* MARK: - Private Properties
    
    private let path: CGPath
    private let minMaxFullRange: MinMaxRange
    
    // ******************************* MARK: - Initialization and Setup
    
    public init?(name: String, lineColor: UIColor, points: [Point]) {
        guard points.hasElements else { return nil }
        
        self.name = name
        self.points = points
        self.lineColor = lineColor
        self.lastIndex = points.count.asCGFloat - 1
        
        self.minValue = points
            .map { $0.value }
            .min() ?? 0
        
        self.maxValue = points
            .map { $0.value }
            .max() ?? 100
        
        self.path = f_getPath(points: points)
        self.minMaxFullRange = MinMaxRange(min: self.minValue, max: self.maxValue)
    }
    
    // ******************************* MARK: - Internal Methods
    
    func createShapeLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineJoin = .round
        shapeLayer.path = path
        
        return shapeLayer
    }
    
    func updatePath(shapeLayer: CAShapeLayer, transform: CGAffineTransform, animated: Bool) {
        var transform = transform
        let transformedPath = path.copy(using: &transform)
        
        if animated {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = shapeLayer.path
            pathAnimation.duration = UIView.inheritedAnimationDuration > 0 ? UIView.inheritedAnimationDuration : c.defaultAnimationDuration
            pathAnimation.timingFunction = .init(name: .easeInEaseOut)
            pathAnimation.fillMode = .forwards
            shapeLayer.path = transformedPath
            shapeLayer.add(pathAnimation, forKey: pathAnimation.keyPath)
            
        } else {
            shapeLayer.path = transformedPath
        }
    }
    
    func getMinMaxRange(range: Graph.RelativeRange) -> MinMaxRange {
        if range == .full { return minMaxFullRange }
        
        let startIndexCGFloat = (lastIndex * range.from)
        let startIndexInt = startIndexCGFloat.rounded().asInt
        let endIndexCGFloat = (lastIndex * range.to)
        let endIndexInt = endIndexCGFloat.rounded().asInt
        let subpoints = points[startIndexInt...endIndexInt]
        let subvalues = subpoints.map { $0.value }
        let minValue = subvalues.min()!
        let maxValue = subvalues.max()!
        
        return MinMaxRange(min: minValue, max: maxValue)
    }
    
    func getPoint(plotTransform: CGAffineTransform, point: CGPoint) -> Point {
        var index = point.applying(plotTransform.inverted()).x.rounded().asInt
        index = index.clamped(min: 0, max: points.count - 1)
        return points[index]
    }
    
    func transform(point: Point, transform: CGAffineTransform) -> CGPoint {
        guard let index = points.firstIndex(of: point) else { return .zero }
        let pointCGPoint = CGPoint(x: index.asCGFloat, y: point.value)
        return pointCGPoint.applying(transform)
    }
    
    // ******************************* MARK: - Private Methods
    
    private func getPartialValue(leftValue: CGFloat, rightValue: CGFloat, leftToRightProgress: CGFloat) -> CGFloat {
        return (rightValue - leftValue) * leftToRightProgress + leftValue
    }
}
}

// ******************************* MARK: - Equatable

extension Graph.Plot: Equatable {
    public static func == (lhs: Graph.Plot, rhs: Graph.Plot) -> Bool {
        return lhs.name == rhs.name
    }
}

// ******************************* MARK: - Hashable

extension Graph.Plot: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

// ******************************* MARK: - Helper Functions

private func f_getPath(points: [Graph.Plot.Point]) -> CGPath {
    let path = CGMutablePath()
    
    // Start from first
    guard let firstPoint = points.first else { return path }
    
    let startPoint = CGPoint(x: 0, y: firstPoint.value)
    path.move(to: startPoint)
    
    // Add lines to other points
    for index in points.indices.dropFirst() {
        let point = points[index]
        let nextPointX = index.asCGFloat
        let nextPointY = point.value
        let nextPoint = CGPoint(x: nextPointX, y: nextPointY)
        path.addLine(to: nextPoint)
    }
    
    return path.copy()!
}
