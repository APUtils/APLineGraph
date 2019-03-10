//
//  UIView+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

// ******************************* MARK: - Constraints

extension UIView {
    /// Creates constraints between self and provided view for top, bottom, leading and trailing sides.
    func constraintSides(to view: UIView) {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(topAnchor.constraint(equalTo: view.topAnchor))
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
}
