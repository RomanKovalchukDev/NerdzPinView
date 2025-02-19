//
//  UIView+FillView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.02.2025.
//

import UIKit

extension UIView {
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
