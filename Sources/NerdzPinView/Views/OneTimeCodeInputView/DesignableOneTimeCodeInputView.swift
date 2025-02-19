//
//  DesignableOneTimeCodeInputView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.02.2025.
//

import UIKit

@MainActor
public final class DesignableOneTimeCodeInputView: UIView {
    
    // MARK: - Aliases
    
    public typealias PinViewType = OneTimeCodeInputView<OneTimeItemView>
    
    // MARK: - Internal types

    private enum Constants {
        enum PinView {
            static let pinLength: Int = 6
            static let font = UIFont.systemFont(ofSize: 14)
            static let backgroundColor = UIColor.lightGray
            static let activeBackgroundColor = UIColor.white
            static let errorBackgoroundColor = UIColor.white
            static let defaultBorderColor = backgroundColor
            static let activeBorderColor = UIColor.green
            static let errorBorderColor = UIColor.systemRed
            static let borderWidth: CGFloat = 1
            static let tintColor = UIColor.black
        }
    }
    
    // MARK: - Properties(public)
    
    public var pinView: PinViewType = {
        let view = PinViewType()
        view.config = PinViewType.Config(pinLength: 6)
        view.layoutConfig = OneTimeItemView.LayoutConfig(cornerRadius: .zero)
        view.appearanceConfig = OneTimeItemView.AppearanceConfig(
            defaultBackgroundColor: Constants.PinView.backgroundColor,
            activeBackgroundColor: Constants.PinView.activeBackgroundColor,
            errorBackgroundColor: Constants.PinView.errorBackgoroundColor,
            defaultValueColor: Constants.PinView.tintColor,
            activeValueColor: Constants.PinView.activeBorderColor,
            errorValueColor: Constants.PinView.errorBackgoroundColor,
            cursorColor: Constants.PinView.tintColor,
            font: Constants.PinView.font
        )
        return view
    }()
    
    public var onPinViewEnteredFully: PinCodeTextAction? {
        get {
            pinView.onPinViewEnteredFully
        }
        
        set {
            pinView.onPinViewEnteredFully = newValue
        }
    }
    
    public var onPinValueChanged: PinCodeTextAction? {
        get {
            pinView.onPinValueChanged
        }
        
        set {
            pinView.onPinValueChanged = newValue
        }
    }
    
    public var onBecomeFirstResponder: PinCodeEmptyAction? {
        get {
            pinView.onBecomeFirstResponder
        }
        
        set {
            pinView.onBecomeFirstResponder = newValue
        }
    }
    
    public var onResignFirstResponder: PinCodeEmptyAction? {
        get {
            pinView.onResignFirstResponder
        }
        
        set {
            pinView.onResignFirstResponder = newValue
        }
    }
    
    public var value: String {
        get {
            pinView.value
        }
        
        set {
            pinView.value = newValue
        }
    }
    
    public var config: PinViewType.Config {
        get {
            pinView.config
        }
        
        set {
            pinView.config = newValue
        }
    }
    
    public var viewState: PinViewType.ViewState {
        get {
            pinView.viewState
        }
        
        set {
            pinView.viewState = newValue
        }
    }
    
    public var layoutConfig: OneTimeItemView.LayoutConfig {
        get {
            pinView.layoutConfig
        }
        
        set {
            pinView.layoutConfig = newValue
        }
    }
    
    public var appearanceConfig: OneTimeItemView.AppearanceConfig {
        get {
            pinView.appearanceConfig
        }
        
        set {
            pinView.appearanceConfig = newValue
        }
    }
    
    public override var canBecomeFirstResponder: Bool {
        false
    }
    
    // MARK: - UIKeyInput
    
    public var hasText: Bool {
        pinView.hasText
    }
    
    public var autocorrectionType: UITextAutocorrectionType {
        get {
            pinView.autocorrectionType
        }
        
        set {
            pinView.autocorrectionType = newValue
        }
    }
    
    public var keyboardType: UIKeyboardType {
        get {
            pinView.keyboardType
        }
        
        set {
            pinView.keyboardType = newValue
        }
    }
    
    public var returnKeyType: UIReturnKeyType {
        get {
            pinView.returnKeyType
        }
        
        set {
            pinView.returnKeyType = newValue
        }
    }
    
    public var textContentType: UITextContentType! {
        get {
            pinView.textContentType
        }
        
        set {
            pinView.textContentType = newValue
        }
    }
    
    // MARK: - Life cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialConfiguration()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialConfiguration()
    }
    
    // MARK: - Methods(public)
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        pinView.canPerformAction(action, withSender: sender)
    }
    
    public override func paste(_ sender: Any?) {
        pinView.paste(sender)
    }
    
    // MARK: - UIResponder
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        pinView.becomeFirstResponder()
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        pinView.resignFirstResponder()
    }
    
    public func initialConfiguration() {
        addAndFillSubview(pinView, directionalLayoutMargins: .zero)
    }
}
