//
//  TapableView.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 20.11.2024.
//

import UIKit

public class PinTapableView: UIView {
    
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
https://github.com/RomanKovalchukDev/NerdzPinView/tree/main/Samples/NerdzPinSwiftUISample
