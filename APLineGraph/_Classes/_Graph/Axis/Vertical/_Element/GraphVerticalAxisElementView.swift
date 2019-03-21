//
//  GraphVerticalAxisElementView.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/21/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


final class GraphVerticalAxisElementView: UIView {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var helperGuide: UIView!
    
    // ******************************* MARK: - Private Properties
    
    // ******************************* MARK: - Initialization and Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        
    }
    
    // ******************************* MARK: - Configuration
    
    // ******************************* MARK: - UIView Overrides
    
    // ******************************* MARK: - Public Methods
    
    // ******************************* MARK: - Private Methods
}

// ******************************* MARK: - InstantiatableFromXib

extension GraphVerticalAxisElementView: InstantiatableFromXib {}
