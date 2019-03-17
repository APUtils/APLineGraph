//
//  GraphAxis.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static let fontSize: CGFloat = 11
    static let font: UIFont = UIFont.systemFont(ofSize: fontSize)
    static let textColor: UIColor = #colorLiteral(red: 0.5960784314, green: 0.6196078431, blue: 0.6392156863, alpha: 1)
}


extension Graph {
class Axis: UIView {
    
    // ******************************* MARK: - Metaclass
    
    static let labelFont = c.font
    
    // ******************************* MARK: - Internal Properties
    
    private lazy var labelsReuseController: ReuseController<UILabel> = ReuseController<UILabel> {
        let label = UILabel(frame: .zero)
        label.font = c.font
        label.textColor = c.textColor
        label.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        return label
    }
    
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
    
    func dequeueLabel(text: String) -> UILabel {
        let label = labelsReuseController.dequeue()
        label.text = text
        label.sizeToFit()
        label.frame.origin = .zero
        
        return label
    }
    
    func queueLabel(_ label: UILabel) {
        labelsReuseController.queue(label)
    }
    
    func queueAllLabels() {
        labelsReuseController.queueAll()
    }
}
}
