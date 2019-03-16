//
//  GraphAxis.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static let fontSize: CGFloat = 10
    static let font: UIFont = UIFont.systemFont(ofSize: fontSize)
    static let textColor: UIColor = #colorLiteral(red: 0.5960784314, green: 0.6196078431, blue: 0.6392156863, alpha: 1)
}


extension Graph {
class Axis: UIView {
    
    // ******************************* MARK: - Metaclass
    
    static let labelFont = c.font
    
    // ******************************* MARK: - Initialization
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }
    
    // ******************************* MARK: - Update
    
    open func update() {
        fatalError("Should be overrided in a child class")
    }
    
    // ******************************* MARK: - Reuse
    
    private var reusableLabels: [UILabel] = []
    
    func dequeueLabel(text: String) -> UILabel {
        let label: UILabel
        if reusableLabels.hasElements {
            label = reusableLabels.removeFirst()
        } else {
            label = UILabel(frame: .zero)
            label.font = c.font
            label.textColor = c.textColor
            label.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        }
        
        label.text = text
        label.sizeToFit()
        label.frame.origin = .zero
        
        return label
    }
    
    func queueLabel(label: UILabel) {
        reusableLabels.append(label)
    }
}
}
