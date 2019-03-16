//
//  ScrollView.swift
//  Base Classes
//
//  Created by Anton Plebanovich on 19.05.16.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


/// ScrollView with decreased button touch delay and ability to show message when content is empty.
/// It also have activity indicator that always stays in center.
open class ScrollView: UIScrollView {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        setupFastTouches()
    }
    
    private func setupFastTouches() {
        delaysContentTouches = false
    }
    
    // ******************************* MARK: - UIScrollView Methods
    
    override open func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        
        return super.touchesShouldCancel(in: view)
    }
}
