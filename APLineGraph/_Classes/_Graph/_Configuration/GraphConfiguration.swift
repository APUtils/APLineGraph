//
//  GraphConfiguration.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit


public extension Graph {
public struct Configuration {
    public var animationDuration: TimeInterval = 0.2
    public var axisLabelColor: UIColor = #colorLiteral(red: 0.5960784314, green: 0.6196078431, blue: 0.6392156863, alpha: 1)
    public var axisLabelFont: UIFont = .systemFont(ofSize: 11)
    public var enableInspection: Bool = false
    public var helpLinesColor: UIColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
    public var inspectionBlurEffect: UIBlurEffect.Style = .light
    public var inspectionGuideColor: UIColor = #colorLiteral(red: 0.8117647059, green: 0.8196078431, blue: 0.8235294118, alpha: 1)
    public var inspectionTextColor: UIColor = #colorLiteral(red: 0.5960784314, green: 0.6196078431, blue: 0.6392156863, alpha: 1)
    public var lineWidth: CGFloat = 1
    public var plotInspectionPointCenterColor: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    public var showAxises: Bool = false
    public var verticalAxisRegionDivideModes: [Graph.VerticalAxis.RegionDivideMode] = .default
    public var verticalPercentGap: CGFloat = 0.1
}
}

extension Graph.Configuration: Equatable {}

// ******************************* MARK: - Computed Properties

public extension Graph.Configuration {
    public static let `default` = Graph.Configuration()
}
