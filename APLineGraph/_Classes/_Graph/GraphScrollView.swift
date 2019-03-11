//
//  GraphScrollView.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/12/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


final class GraphScrollView: UIScrollView {
    
    // ******************************* MARK: - Types
    
    typealias OnSizeDidChange = () -> Void
    
    // ******************************* MARK: - Private Properties
    
    private let onSizeDidChange: OnSizeDidChange
    
    // ******************************* MARK: - Initialization and Setup
    
    init(onSizeDidChange: @escaping OnSizeDidChange) {
        self.onSizeDidChange = onSizeDidChange
        super.init(frame: UIScreen.main.bounds)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ******************************* MARK: - UIView Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        onSizeDidChange()
    }
}
