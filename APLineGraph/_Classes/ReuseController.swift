//
//  ReuseController.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


final class ReuseController<T: Equatable> {
    
    // ******************************* MARK: - Types
    
    typealias Create = () -> T
    typealias PrepareForReuse = (T) -> Void
    
    // ******************************* MARK: - Private Properties
    
    private let create: Create
    private let prepareForReuse: PrepareForReuse
    private var vacantReusables: [T] = []
    private var takenReusables: [T] = []
    
    // ******************************* MARK: - Initialization and Setup
    
    init(create: @escaping Create, prepareForReuse: @escaping PrepareForReuse) {
        self.create = create
        self.prepareForReuse = prepareForReuse
    }
    
    // ******************************* MARK: - Internal Methods
    
    func dequeue() -> T {
        let reusable: T
        if vacantReusables.hasElements {
            reusable = vacantReusables.removeFirst()
        } else {
            reusable = create()
        }
        
        takenReusables.append(reusable)
        
        return reusable
    }
    
    func queue(_ reusable: T) {
        prepareForReuse(reusable)
        takenReusables.remove(reusable)
        vacantReusables.append(reusable)
    }
    
    func queueAll() {
        takenReusables.forEach(queue)
    }
    
    func removeAll() {
        takenReusables = []
        vacantReusables = []
    }
}

// ******************************* MARK: - UIView

extension ReuseController where T: UIView {
    convenience init(create: @escaping Create) {
        self.init(create: create) { $0.removeFromSuperview() }
    }
}
