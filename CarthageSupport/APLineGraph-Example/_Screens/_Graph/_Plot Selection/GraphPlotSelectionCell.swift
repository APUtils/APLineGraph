//
//  GraphPlotSelectionCell.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


final class GraphPlotSelectionCell: UITableViewCell {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var plotColorView: UIView!
    @IBOutlet private weak var plotNameLabel: UILabel!
    
    // ******************************* MARK: - Configuration
    
    func configure(vm: GraphPlotSelectionCellVM) {
        plotColorView.backgroundColor = vm.color
        plotNameLabel.text = vm.name
        accessoryType = vm.selected ? .checkmark : .none
    }
}
