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
    static let sideControlWidth: CGFloat = 32 / 3
    static let sideControlEnlargedWidth: CGFloat = 30
    static let sideControlEnlargedHalfWidth: CGFloat = sideControlEnlargedWidth / 2
    static let minWidth: CGFloat = sideControlEnlargedWidth
}


final class RangeControlView: UIView {
    
    // ******************************* MARK: - Types
    
    typealias OnRangeChange = (Graph.Range) -> Void
    
    // ******************************* MARK: - Public Properties
    
    var onRangeDidChange: OnRangeChange?
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    
    // ******************************* MARK: - Private Properties
    
    private var action: Action?
    
    
    // TODO: Rework to touches or custom recognizer
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPanChange(_:)))
    
    // ******************************* MARK: - Initialization and Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        createAndAttachContentView()
        addGestureRecognizer(panGestureRecognizer)
    }
    
    // ******************************* MARK: - Configuration
    
    // ******************************* MARK: - UIView Overrides
    
    // ******************************* MARK: - Public Methods
    
    /// Configure view with provided view model
    /// - parameter vm: View model to use for setup
    func configure(vm: RangeControlVM) {
        
    }
    
    // ******************************* MARK: - Actions
    
    @objc private func onPanChange(_ panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            let pointX = panGestureRecognizer.location(in: panGestureRecognizer.view).x
            let leftControlLeftSide = leftConstraint.constant
            let leftControlMinX = max(leftControlLeftSide - c.sideControlEnlargedHalfWidth, 0)
            let leftControlMaxX = leftControlLeftSide + c.sideControlWidth + min(c.sideControlEnlargedHalfWidth, widthConstraint.constant / 2)
            
            let rightControlRightSide = leftConstraint.constant + widthConstraint.constant
            let rightControlMinX = rightControlRightSide - c.sideControlWidth - min(c.sideControlEnlargedHalfWidth, widthConstraint.constant / 2)
            let rightControlMaxX = min(rightControlRightSide + c.sideControlEnlargedHalfWidth, bounds.size.width)
            
            if pointX < leftControlMinX {
                // Ignore
            } else if pointX >= leftControlMinX && pointX <= leftControlMaxX {
                action = .adjustLeft(left: leftConstraint.constant, width: widthConstraint.constant)
            } else if pointX > leftControlMaxX && pointX < rightControlMinX {
                action = .move(left: leftConstraint.constant, width: widthConstraint.constant)
            } else if pointX >= rightControlMinX && pointX <= rightControlMaxX {
                action = .adjustRight(left: leftConstraint.constant, width: widthConstraint.constant)
            } else {
                // Ignore
            }
            
        case .changed:
            guard let action = action else { return }
            
            let translationX = panGestureRecognizer.translation(in: panGestureRecognizer.view).x
            let boundsWidth = bounds.width
            
            switch action {
            case .adjustLeft(let left, let width):
                let clampedTranslation = translationX.clamped(min: -left, max: width)
                leftConstraint.constant = left + clampedTranslation
                widthConstraint.constant = max(width - clampedTranslation, c.minWidth)
                
            case .adjustRight(let left, let width):
                let clampedTranslation = translationX.clamped(min: -width, max: boundsWidth - width - left)
                widthConstraint.constant = max(width + clampedTranslation, c.minWidth)
                
            case .move(let left, let width):
                let clampedTranslation = translationX.clamped(min: -left, max: boundsWidth - width - left)
                leftConstraint.constant = left + clampedTranslation
            }
            
            let from = leftConstraint.constant / boundsWidth
            let to = (leftConstraint.constant + widthConstraint.constant) / boundsWidth
            let range = Graph.Range(from: from, to: to)
            print(range)
            onRangeDidChange?(range)
            
        case .cancelled, .ended, .failed:
            action = nil
            
        case .possible:
            break
        }
    }
    
    // ******************************* MARK: - Private Methods
    
    
}

// ******************************* MARK: - InstantiatableContentView

extension RangeControlView: InstantiatableContentView {}
