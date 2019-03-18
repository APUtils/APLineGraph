//
//  GraphInspectionView.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static let valueLabelFontSize: CGFloat = 12
    static let valueLabelFont: UIFont = .boldSystemFont(ofSize: valueLabelFontSize)
}


final class GraphInspectionView: UIView {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var containerView: UIVisualEffectView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var valuesStackView: UIStackView!
    
    // ******************************* MARK: - Private Properties
    
    private let valueLabelsReuseController: ReuseController<UILabel> = ReuseController<UILabel> {
        let label = UILabel()
        label.font = c.valueLabelFont
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        
        return label
    }
    
    // ******************************* MARK: - Configuration
    
    func configure(vm: GraphInspectionVM) {
        containerView.effect = UIBlurEffect(style: vm.configuration.inspectionBlurEffect)
        
        dateLabel.text = vm.date
        dateLabel.textColor = vm.configuration.inspectionTextColor
        
        yearLabel.text = vm.year
        yearLabel.textColor = vm.configuration.inspectionTextColor
        
        valueLabelsReuseController.queueAll()
        vm.values
            .sorted { $0.value > $1.value }
            .map {
                let label = valueLabelsReuseController.dequeue()
                label.text = $0.value.asString
                label.textColor = $0.color
                return label
            }
            .forEach(valuesStackView.addArrangedSubview)
    }
    
    // ******************************* MARK: - UIView Overrides
    
    // ******************************* MARK: - Public Methods
    
    // ******************************* MARK: - Private Methods
}

// ******************************* MARK: - InstantiatableFromXib

extension GraphInspectionView: InstantiatableFromXib {}
