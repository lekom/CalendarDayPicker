//
//  UIView+Anchors.swift
//
//  Created by Leko Murphy on 1/7/20.
//  Copyright © 2020 Leko Murphy. All rights reserved.
//

import UIKit

extension UIView {
    func pinEdgesToSuperView() {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
    }
    
    func pinEdgesToSuperView(withInset inset: CGFloat) {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor, constant: inset).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -inset).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: inset).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -inset).isActive = true
    }
    
    func pinEdgesToSuperViewSafeAreaLayoutGuide() {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    func pinBottomAndSidesToSuperView() {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
    }
    
    func pinBottomAndSidesToSuperViewSafeAreaLayoutGuide() {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    func pinTopAndSidesToSuperViewSafeAreaLayoutGuide() {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    func pinSidesToSuperView() {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    func setHeight(constant: CGFloat) {
        self.setConstraint(value: constant, attribute: .height)
    }
    
    func setWidth(constant: CGFloat) {
        self.setConstraint(value: constant, attribute: .width)
    }
    
    private func setConstraint(value: CGFloat, attribute: NSLayoutConstraint.Attribute) {
        removeConstraint(attribute: attribute)
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1,
                                            constant: value)
        self.addConstraint(constraint)
    }
    
    private func removeConstraint(attribute: NSLayoutConstraint.Attribute) {
        self.constraints.forEach {
            if $0.firstAttribute == attribute {
                self.removeConstraint($0)
            }
        }
    }
}
