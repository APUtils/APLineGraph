//
//  Instantiatable.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/12/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

// ******************************* MARK: - InstantiatableFromStoryboard

/// Helps to instantiate object from storyboard file.
public protocol InstantiatableFromStoryboard: class {
    static var storyboardName: String { get }
    static var storyboardID: String { get }
    static func create() -> Self
    static func createWithNavigationController() -> (UINavigationController, Self)
}

public extension InstantiatableFromStoryboard where Self: UIViewController {
    private static func controllerFromStoryboard<T>() -> T {
        let storyboardName = self.storyboardName
        if let initialVc = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController() as? T {
            return initialVc
        } else {
            return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: className) as! T
        }
    }
    
    /// Name of storyboard that contains this view controller.
    /// If not specified uses view controller's class name without "ViewController" postfix.
    public static var storyboardName: String {
        return className.replacingOccurrences(of: "VC", with: "")
    }
    
    /// View controller storyboard ID.
    /// By default uses view controller's class name.
    public static var storyboardID: String {
        return className
    }
    
    /// Instantiates view controller from storyboard file.
    /// By default uses view controller's class name without "ViewController" postfix for `storyboardName` and view controller's class name for `storyboardID`.
    /// Implement `storyboardName` if you want to secify custom storyboard name.
    /// Implement `storyboardID` if you want to specify custom storyboard ID.
    public static func create() -> Self {
        return controllerFromStoryboard()
    }
    
    /// Instantiates view controller from storyboard file wrapped into navigation controller.
    /// By default uses view controller's class name without "ViewController" postfix for `storyboardName` and view controller's class name for `storyboardID`.
    /// Implement `storyboardName` if you want to secify custom storyboard name.
    /// Implement `storyboardID` if you want to specify custom storyboard ID.
    public static func createWithNavigationController() -> (UINavigationController, Self) {
        let vc = create()
        let navigationVc = UINavigationController(rootViewController: vc)
        
        return (navigationVc, vc)
    }
}

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
