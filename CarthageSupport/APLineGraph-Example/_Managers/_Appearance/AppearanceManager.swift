//
//  AppearanceManager.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/17/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import Foundation
import UIKit


protocol AppearanceManagerStyleListener: class {
    func appearanceManager(_ appearanceManager: AppearanceManager, didChangeStyle style: AppearanceManager.Style)
}


final class AppearanceManager {
    
    // ******************************* MARK: - Singleton
    
    static let shared = AppearanceManager()
    
    // ******************************* MARK: - Public Properties
    
    private let styleUserDefaultsKey = "style"
    var style: Style {
        get {
            return Style(rawValue: UserDefaults.standard.integer(forKey: styleUserDefaultsKey)) ?? .day
        }
        set {
            guard style != newValue else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: styleUserDefaultsKey)
            update()
        }
    }
    
    // ******************************* MARK: - Private Properties
    
    private var primeViews = NSHashTable<UIView>(options: [.weakMemory])
    private var secondaryViews = NSHashTable<UIView>(options: [.weakMemory])
    private var separatorViews = NSHashTable<UIView>(options: [.weakMemory])
    private var separatorsTableView = NSHashTable<UITableView>(options: [.weakMemory])
    private var onSecondaryLabels = NSHashTable<UILabel>(options: [.weakMemory])
    private var styleListeners = NSHashTable<AnyObject>(options: [.weakMemory])
    
    // ******************************* MARK: - Initialization and Setup
    
    init() {
        update()
    }
    
    // ******************************* MARK: - Public Methods
    
    func addOnSecondaryLabel(_ label: UILabel) {
        configure(onSecondaryLabel: label)
        onSecondaryLabels.add(label)
    }
    
    func addPrimeView(_ view: UIView) {
        configure(primeView: view)
        primeViews.add(view)
    }
    
    func addSeparatorView(_ view: UIView) {
        configure(separatorView: view)
        separatorViews.add(view)
    }
    
    func addSeparatorsTableView(_ view: UITableView) {
        configure(separatorsTableView: view)
        separatorsTableView.add(view)
    }
    
    func addSecondaryView(_ view: UIView) {
        configure(secondaryView: view)
        secondaryViews.add(view)
    }
    
    func addStyleListener(_ listener: AppearanceManagerStyleListener) {
        configure(styleListener: listener)
        styleListeners.add(listener)
    }
    
    func toggleStyle() {
        switch style {
        case .day: style = .night
        case .night: style = .day
        }
    }
    
    // ******************************* MARK: - Private Methods
    
    private func update() {
        primeViews.allObjects.forEach(configure(primeView:))
        secondaryViews.allObjects.forEach(configure(secondaryView:))
        separatorViews.allObjects.forEach(configure(separatorView:))
        separatorsTableView.allObjects.forEach(configure(separatorsTableView:))
        onSecondaryLabels.allObjects.forEach(configure(onSecondaryLabel:))
        styleListeners.allObjects.forEach(configure(styleListener:))
        updateStatusBar()
    }
    
    private func configure(primeView: UIView) {
        if let navigationBar = primeView as? UINavigationBar {
            configure(navigationBar: navigationBar)
        } else {
            primeView.backgroundColor = style.primaryColor
        }
    }
    
    private func configure(secondaryView: UIView) {
        if let navigationBar = secondaryView as? UINavigationBar {
            configure(navigationBar: navigationBar)
        } else {
            secondaryView.backgroundColor = style.secondaryColor
        }
    }
    
    private func configure(separatorView: UIView) {
        separatorView.backgroundColor = style.separatorColor
    }
    
    private func configure(separatorsTableView: UITableView) {
        separatorsTableView.separatorColor = style.separatorColor
    }
    
    private func configure(onSecondaryLabel: UILabel) {
        onSecondaryLabel.textColor = style.onSecondaryColor
    }
    
    private func configure(styleListener: AnyObject) {
        guard let styleListener = styleListener as? AppearanceManagerStyleListener else { return }
        styleListener.appearanceManager(self, didChangeStyle: style)
    }
    
    private func configure(navigationBar: UINavigationBar) {
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: style.onSecondaryColor]
        navigationBar.barTintColor = style.primaryColor
        navigationBar.tintColor = style.onSecondaryColor
    }
    
    private func updateStatusBar() {
        UIApplication.shared.statusBarStyle = style.statusBarStyle
    }
}
