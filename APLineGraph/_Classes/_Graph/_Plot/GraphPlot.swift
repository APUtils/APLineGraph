//
//  GraphPlot.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit


public extension Graph {
final class Plot {
    
    // ******************************* MARK: - Types
    
    struct AnimationPair {
        let from: CGFloat
        let to: CGFloat
    }
    
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
    private var reducedPaths: [Int: CGPath] = [:]
    
    // ******************************* MARK: - Initialization and Setup
    
    public init?(name: String, lineColor: UIColor, points: [Point]) {
        guard points.hasElements else { return nil }
        
        self.name = name
        self.points = points
        self.lineColor = lineColor
        self.lastIndex = points.count.asCGFloat - 1
        
        let minMax = points
            .map { $0.value }
            .minMax
        
        self.minValue = minMax.0
        self.maxValue = minMax.1
        
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
    
    func updatePath(shapeLayer: CAShapeLayer, translateX: CGFloat, scaleX: CGFloat, sizeY: CGFloat, transform: CGAffineTransform, duration: TimeInterval) {
        // Idea here is that we never animate X transformations but always animate Y transformations
        
        // TODO: There is one more big optimization - reduced path should not contain points outside of visible zone. Only two side points so scale will work as always. Though, it isn't a bottle neck right now even for 30k points. And 30k points graphs aren't very usable with current UI.
        
        // Using reduced path if possible
        let path = getReducedPath(layerWidth: shapeLayer.bounds.width, scaleX: scaleX)
        
        // End transform and path
        var endTransform = transform
        let endPath = path.copy(using: &endTransform)!
        
        // If duration is less then one frame in 60 fps then just set new value
        // 1 / 60 = 0.0166666...
        if duration > 0.0166 {
            
            // Getting current Y transform params
            let currentPath = shapeLayer.presentation()?.path ?? shapeLayer.path ?? endPath
            let currentPathBoundingBoxOfPath = currentPath.boundingBoxOfPath
            let pathBoundingBoxOfPath = path.boundingBoxOfPath
            let currentScaleY = currentPathBoundingBoxOfPath.height / pathBoundingBoxOfPath.height
            let currentTranslateY = -(path.currentPoint.y + currentPath.currentPoint.y / currentScaleY)
            
            // Calculate start transform and path using current Y params and new X params
            var startTransform = CGAffineTransform
                .identity
                .scaledBy(x: scaleX, y: -currentScaleY)
                .translatedBy(x: translateX, y: currentTranslateY)
            
            let startPath = path.copy(using: &startTransform)
            
            // Animate
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = startPath
            pathAnimation.duration = duration
            pathAnimation.timingFunction = .init(name: .linear)
            pathAnimation.fillMode = .forwards
            shapeLayer.path = endPath
            
            shapeLayer.removeAnimation(forKey: "path")
            shapeLayer.add(pathAnimation, forKey: pathAnimation.keyPath)
            
        } else {
            shapeLayer.path = endPath
        }
    }
    
    func getMinMaxRange(layerWidth: CGFloat, range: Graph.RelativeRange) -> MinMaxRange {
        if range == .full { return minMaxFullRange }

        let startIndexCGFloat = (lastIndex * range.from)
        let startIndexInt = startIndexCGFloat.rounded().asInt
        let endIndexCGFloat = (lastIndex * range.to)
        let endIndexInt = endIndexCGFloat.rounded().asInt
        let minMax = points[startIndexInt...endIndexInt]
            .minMax

        return MinMaxRange(min: minMax.0.value, max: minMax.1.value)
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
    
    private func getReductionCoef(layerWidth: CGFloat, scaleX: CGFloat) -> Int {
        let pointsCount = points.count
        let visibleSize = scaleX * pointsCount.asCGFloat / layerWidth
        return (pointsCount.asCGFloat / layerWidth / visibleSize).asInt
    }
    
    private func getReductionCoef(layerWidth: CGFloat, range: Graph.RelativeRange) -> Int {
        let pointsCount = points.count
        return (pointsCount.asCGFloat / layerWidth * range.size).asInt
    }
    
    private func getReducedPath(layerWidth: CGFloat, scaleX: CGFloat) -> CGPath {
        let pointsCount = points.count
        let reductionCoef = getReductionCoef(layerWidth: layerWidth, scaleX: scaleX)
        if reductionCoef < 2 { return path }
        if let reducedPath = reducedPaths[reductionCoef] { return reducedPath }
        
        let step = reductionCoef
        var i = step
        let reducedPath = CGMutablePath()
        let initialPoint = CGPoint(x: 0, y: points[0].value)
        var previous = points[0].value
        reducedPath.move(to: initialPoint)
        while i < pointsCount {
            let slice = points[i-step...i]
            let nextPointX = i.asCGFloat
            
            let max = slice.max()!.value
            let min = slice.min()!.value
            let diffWithMax = abs(previous - max)
            let diffWithMin = abs(previous - min)
            
            let nextPointY: CGFloat
            if diffWithMax > diffWithMin {
                nextPointY = max
            } else {
                nextPointY = min
            }
            
            let nextPoint = CGPoint(x: nextPointX, y: nextPointY)
            reducedPath.addLine(to: nextPoint)
            
            i += step
            previous = nextPointY
        }
        
        // Add last point
        i -= step
        let lastIndex = pointsCount - 1
        if i < lastIndex {
            let point = points[lastIndex]
            let nextPointX = lastIndex.asCGFloat
            let nextPointY = point.value
            let nextPoint = CGPoint(x: nextPointX, y: nextPointY)
            reducedPath.addLine(to: nextPoint)
        }
        
        reducedPaths[reductionCoef] = reducedPath
        
        return reducedPath
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
    
    return path
}
