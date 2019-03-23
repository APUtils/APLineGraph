//
//  Globals.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/23/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


let g: Globals = Globals()

final class Globals {
    
    // ******************************* MARK: - Typealiases
    
    /// Closure that takes Void and returns Void.
    typealias SimpleClosure = () -> Void
    
    // ******************************* MARK: - Animations
    
    func animateIfNeeded(_ duration: TimeInterval, animations: @escaping SimpleClosure) {
        animateIfNeeded(duration, animations: animations, completion: nil)
    }
    
    func animateIfNeeded(_ duration: TimeInterval, options: UIView.AnimationOptions, animations: @escaping SimpleClosure) {
        animateIfNeeded(duration, options: options, animations: animations, completion: nil)
    }
    
    func animateIfNeeded(_ duration: TimeInterval, delay: TimeInterval = 0, options: UIView.AnimationOptions = .curveLinear, animations: @escaping SimpleClosure, completion: ((Bool) -> ())? = nil) {
        
        if duration <= c.minimumAnimationDuration {
            animations()
            completion?(true)
        } else {
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: completion)
        }
    }
}
