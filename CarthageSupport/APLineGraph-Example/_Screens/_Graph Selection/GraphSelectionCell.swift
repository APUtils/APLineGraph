//
//  GraphSelectionCell.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


final class GraphSelectionCell: UITableViewCell {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var label: UILabel!
    
    // ******************************* MARK: - Configuration
    
    func configure(vm: GraphSelectionCellVM) {
        label.text = vm.text
    }
}
