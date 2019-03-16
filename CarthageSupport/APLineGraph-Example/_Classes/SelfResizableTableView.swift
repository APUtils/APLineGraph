//
//  SelfResizableTableView.swift
//  Base Classes
//
//  Created by Anton Plebanovich on 9/14/17.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


class SelfResizableTableView: TableView {
    
    // ******************************* MARK: - UIView Overrides
    
    override var contentSize: CGSize {
        didSet {
            guard oldValue != contentSize else { return }
            
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = contentSize
        intrinsicContentSize.height += contentInset.top
        intrinsicContentSize.height += contentInset.bottom
        intrinsicContentSize.width += contentInset.left
        intrinsicContentSize.width += contentInset.right
        
        return intrinsicContentSize
    }
}
