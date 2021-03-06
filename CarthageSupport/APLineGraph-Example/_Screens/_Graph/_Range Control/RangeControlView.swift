//
//  RangeControlView.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/12/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit
import APLineGraph


extension Constants {
    static let sideMargin: CGFloat = 16
    static let sideControlWidth: CGFloat = 32 / 3
    static let sideControlAllowedWidthToCenterRelative: CGFloat = 0.1
    static let sideControlEnlargedWidth: CGFloat = 30
    static let sideControlEnlargedHalfWidth: CGFloat = sideControlEnlargedWidth / 2
    static let minWidth: CGFloat = sideControlWidth * 2
}


final class RangeControlView: UIView {
    
    // ******************************* MARK: - Types
    
    typealias OnRangeChange = (Graph.RelativeRange) -> Void
    typealias OnStartTouching = () -> Void
    typealias OnStopTouching = () -> Void
    
    // ******************************* MARK: - Public Properties
    
    private(set) var range: Graph.RelativeRange = .full
    var onRangeDidChange: OnRangeChange?
    var onStartTouching: OnStartTouching?
    var onStopTouching: OnStopTouching?
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rangeControlImageView: UIImageView!
    
    // ******************************* MARK: - Private Properties
    
    private var actions: [UITouch: Action] = [:]
    
    // ******************************* MARK: - Initialization and Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        createAndAttachContentView()
        AppearanceManager.shared.addStyleListener(self)
    }
    
    // ******************************* MARK: - Configuration
    
    // ******************************* MARK: - UIView Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        leftConstraint.constant = range.from * bounds.width + c.sideMargin
        widthConstraint.constant = range.size * (bounds.width - 2 * c.sideMargin)
    }
    
    // ******************************* MARK: - Public Methods
    
    /// Configure view with provided view model
    /// - parameter vm: View model to use for setup
    func configure(vm: RangeControlVM) {
        range = vm.initialRange
        layout()
    }
    
    // ******************************* MARK: - Actions
    
    // TODO: Do I actually handle multiple touches correctly? Maybe just switch back to one.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onStartTouching?()
        
        touches.forEach { touch in
            let pointX = touch.location(in: self).x
            let leftControlLeftSide = leftConstraint.constant
            let leftControlMinX = max(leftControlLeftSide - c.sideControlEnlargedHalfWidth, 0)
            let leftControlMaxX = leftControlLeftSide + c.sideControlWidth + min(c.sideControlEnlargedHalfWidth, widthConstraint.constant * c.sideControlAllowedWidthToCenterRelative)
            
            let rightControlRightSide = leftConstraint.constant + widthConstraint.constant
            let rightControlMinX = rightControlRightSide - c.sideControlWidth - min(c.sideControlEnlargedHalfWidth, widthConstraint.constant * c.sideControlAllowedWidthToCenterRelative)
            let rightControlMaxX = min(rightControlRightSide + c.sideControlEnlargedHalfWidth, bounds.size.width)
            
            if pointX < leftControlMinX {
                // Ignore
            } else if pointX >= leftControlMinX && pointX <= leftControlMaxX {
                actions[touch] = .adjustLeft(left: leftConstraint.constant, width: widthConstraint.constant, touchStart: pointX)
            } else if pointX > leftControlMaxX && pointX < rightControlMinX {
                actions[touch] = .move(left: leftConstraint.constant, width: widthConstraint.constant, touchStart: pointX)
            } else if pointX >= rightControlMinX && pointX <= rightControlMaxX {
                actions[touch] = .adjustRight(left: leftConstraint.constant, width: widthConstraint.constant, touchStart: pointX)
            } else {
                // Ignore
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            guard let action = actions[touch] else { return }
            
            let translationX = touch.location(in: self).x - action.touchStart
            let boundsWidth = bounds.width
            
            switch action {
            case .adjustLeft(let left, let width, _):
                let min = -left + c.sideMargin
                let max = width - c.minWidth
                let clampedTranslation = translationX.clamped(min: min, max: max)
                widthConstraint.constant = width - clampedTranslation
                leftConstraint.constant = left + clampedTranslation
                
            case .adjustRight(let left, let width, _):
                let min = c.minWidth - width
                let max = boundsWidth - width - left - c.sideMargin
                let clampedTranslation = translationX.clamped(min: min, max: max)
                widthConstraint.constant = width + clampedTranslation
                
            case .move(let left, let width, _):
                let min = -left + c.sideMargin
                let max = boundsWidth - width - left - c.sideMargin
                let clampedTranslation = translationX.clamped(min: min, max: max)
                leftConstraint.constant = left + clampedTranslation
            }
            
            let availableBounds = boundsWidth - 2 * c.sideMargin
            let left = leftConstraint.constant - c.sideMargin
            let width = widthConstraint.constant
            let from = left / availableBounds
            let to = (left + width) / availableBounds
            range = Graph.RelativeRange(from: from, to: to)
            onRangeDidChange?(range)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { actions[$0] = nil }
        onStopTouching?()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { actions[$0] = nil }
        onStopTouching?()
    }
    
    // ******************************* MARK: - Private Methods
    
    
}

// ******************************* MARK: - InstantiatableContentView

extension RangeControlView: InstantiatableContentView {}

// ******************************* MARK: - AppearanceManagerStyleListener

extension RangeControlView: AppearanceManagerStyleListener {
    func appearanceManager(_ appearanceManager: AppearanceManager, didChangeStyle style: AppearanceManager.Style) {
        switch style {
        case .day: rangeControlImageView.tintColor = #colorLiteral(red: 0.8980392157, green: 0.9176470588, blue: 0.937254902, alpha: 1)
        case .night: rangeControlImageView.tintColor = #colorLiteral(red: 0.2078431373, green: 0.2745098039, blue: 0.3490196078, alpha: 1)
        }
    }
}
