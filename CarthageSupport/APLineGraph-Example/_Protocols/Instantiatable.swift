//
//  Instantiatable.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/12/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

// ******************************* MARK: - InstantiatableContentView

/// Helps to instantiate content view from storyboard file.
protocol InstantiatableContentView {
    func createContentView() -> UIView
}

extension InstantiatableContentView where Self: NSObject {
    /// Instantiates contentView from xib file and making instantiator it's owner.
    /// Xib filename should be composed of className + "ContentView" postfix. E.g. MyView -> MyViewContentView
    func createContentView() -> UIView {
        return UINib(nibName: "\(type(of: self).className)ContentView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
}

extension InstantiatableContentView where Self: UIView {
    /// Instantiates contentView from xib file and making instantiator it's owner.
    /// Xib filename should be composed of className + "ContentView" postfix. E.g. MyView -> MyViewContentView
    /// After creation puts content view as subview to self and constraints sides.
    /// Also makes self background color transparent.
    /// The main idea here is that content view should fully set how self view looks.
    func createAndAttachContentView() {
        backgroundColor = .clear
        let contentView = createContentView()
        contentView.frame = bounds
        addSubview(contentView)
        contentView.constraintSides(to: self)
    }
}
