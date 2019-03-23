//
//  CALayer+Utils.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/19/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


extension CALayer {
    func hideAnimated(completion: (() -> Void)? = nil) {
        opacity = 0
        
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = UIView.inheritedAnimationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        CATransaction.setCompletionBlock(completion)
        add(animation, forKey: "fadeOut")
        CATransaction.commit()
    }
    
    func showAnimated(completion: (() -> Void)? = nil) {
        opacity = 1
        
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = UIView.inheritedAnimationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        CATransaction.setCompletionBlock(completion)
        add(animation, forKey: "fadeIn")
        CATransaction.commit()
    }
}
