//
//  UITableView+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

// ******************************* MARK: - Cells, Header and Footer Reuse and Dequeue

extension UITableView {
    
    // ******************************* MARK: - Cell
    
    /// Simplifies cell registration. Xib name must be the same as class name.
    func registerNib(class: UITableViewCell.Type) {
        register(UINib(nibName: `class`.className, bundle: nil), forCellReuseIdentifier: `class`.className)
    }
    
    /// Simplifies cell dequeue. Specify type of variable on declaration so proper cell will be dequeued.
    ///
    /// Example:
    ///
    ///     let cell: MyCell = tableView.dequeue(for: indexPath)
    func dequeue<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: T.className, for: indexPath) as! T
    }
}
