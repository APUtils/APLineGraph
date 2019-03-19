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


public extension Graph {
public class Axis: UIView {
    
    // ******************************* MARK: - Metaclass
    
    static let labelFont = c.font
    
    // ******************************* MARK: - Internal Properties
    
    private var previousSize: CGSize = .zero
    
    private lazy var labelsReuseController: ReuseController<UILabel> = ReuseController<UILabel>(create: {
        let label = UILabel(frame: .zero)
        label.font = c.font
        label.textColor = c.textColor
        label.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        label.alpha = 0
        
        return label
    }, prepareForReuse: {
        $0.alpha = 0
    })
    
    // ******************************* MARK: - Initialization and Setup
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
    }
    
    // ******************************* MARK: - UIView Methods Overrides
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard previousSize != bounds.size else { return }
        previousSize = bounds.size
        update()
    }
    
    // ******************************* MARK: - Update
    
    open func update() {
        fatalError("Should be overridden in a child class")
    }
    
    // ******************************* MARK: - Reuse
    
    func addLabel(text: String, center: CGPoint) -> UILabel {
        let label = labelsReuseController.dequeueClosest(center: center)
        label.text = text
        label.sizeToFit()
        label.alpha = 1
        label.center = center
        addSubview(label)
        
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
