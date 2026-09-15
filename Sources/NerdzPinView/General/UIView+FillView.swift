//
//  UIView+FillView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.02.2025.
//

import UIKit

extension UIView {
    /// Adds a subview and pins it to the receiver's layout margins guide on every edge.
    ///
    /// - Parameters:
    ///   - view: The subview to add and constrain.
    ///   - directionalLayoutMargins: The margins applied to the receiver before pinning the subview.
    func addAndFillSubview(_ view: UIView, directionalLayoutMargins: NSDirectionalEdgeInsets) {
        self.directionalLayoutMargins = directionalLayoutMargins
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
        ])
    }
}
