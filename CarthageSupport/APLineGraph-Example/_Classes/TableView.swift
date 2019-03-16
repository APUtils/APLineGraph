//
//  TableView.swift
//  Base Classes
//
//  Created by Anton Plebanovich on 19.05.16.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


/// TableView with decreased button touch delay and ability to show message when content is empty.
/// It also have activity indicator that always stays in center.
open class TableView: UITableView {
    
    // ******************************* MARK: - Initialization and Setup
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        setupFastTouches()
    }
    
    private func setupFastTouches() {
        delaysContentTouches = false
        
        for view in subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delaysContentTouches = false
                break
            }
        }
    }
    
    // ******************************* MARK: - UIScrollView Overrides
    
    override open func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        
        return super.touchesShouldCancel(in: view)
    }
}
