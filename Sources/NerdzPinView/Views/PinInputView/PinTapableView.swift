//
//  TapableView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 20.11.2024.
//

import UIKit

/// A base `UIView` that reports taps through a closure.
///
/// It installs a tap gesture recognizer only while ``onViewTapped`` is set, and
/// removes it when the closure is cleared. Predefined item views such as
/// ``BorderedItemView`` and ``UnderlineItemView`` subclass it to forward taps to
/// their container.
public class PinTapableView: UIView {

    /// A closure invoked whenever the view is tapped.
    ///
    /// Assigning a non `nil` value installs the tap gesture recognizer, and
    /// setting it back to `nil` removes it.
    public var onViewTapped: PinCodeEmptyAction? {
        didSet {
            if onViewTapped == nil {
                removeGestureRecognizer(tapGesture)
            }
            else {
                addGestureRecognizer(tapGesture)
            }
        }
    }
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        return tapGesture
    }()
    
    @objc
    private func viewTapped() {
        onViewTapped?()
    }
}
