//
//  GraphInspectionView.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static let valueLabelFont: UIFont = .systemFont(ofSize: 12)
}


final class GraphInspectionView: UIView {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var valuesStackView: UIStackView!
    
    // ******************************* MARK: - Private Properties
    
    private let valueLabelsReuseController: ReuseController<UILabel> = ReuseController<UILabel> {
        let label = UILabel()
        label.font = c.valueLabelFont
        return label
    }
    
    // ******************************* MARK: - Configuration
    
    func configure(vm: GraphInspectionVM) {
        dateLabel.text = vm.date
        yearLabel.text = vm.year

        valueLabelsReuseController.queueAll()
        vm.values
            .map {
                let label = valueLabelsReuseController.dequeue()
                label.text = $0.value
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
