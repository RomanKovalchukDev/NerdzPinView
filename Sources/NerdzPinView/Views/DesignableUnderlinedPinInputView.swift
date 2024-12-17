//
//  DesignableUnderlinedPinInputView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 15.12.2024.
//

import UIKit

@MainActor
open class DesignableUnderlinedPinInputView: UIView, UIKeyInput, @preconcurrency UIEditMenuInteractionDelegate {
    
    // MARK: - Aliases
    
    public typealias PinViewType = PinCodeInputView<UnderlineItemInputView>
    
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
    
    open var pinView: PinViewType = {
        let view = PinViewType()
        view.config = PinViewConfig(pinLength: 6, isContentCentered: false)
        view.layoutConfig = UnderlineItemInputView.LayoutConfig(cornerRadius: .zero)
        view.appearanceConfig = UnderlineItemInputView.AppearanceConfig(
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
    
    public var text: String {
        pinView.text
    }
    
    open var config: PinViewConfig {
        get {
            pinView.config
        }
        
        set {
            pinView.config = newValue
        }
    }
    
    open var viewState: PinViewType.ViewState {
        get {
            pinView.viewState
        }
        
        set {
            pinView.viewState = newValue
        }
    }
    
    open var layoutConfig: UnderlineItemInputView.LayoutConfig {
        get {
            pinView.layoutConfig
        }
        
        set {
            pinView.layoutConfig = newValue
        }
    }
    
    open var appearanceConfig: UnderlineItemInputView.AppearanceConfig {
        get {
            pinView.appearanceConfig
        }
        
        set {
            pinView.appearanceConfig = newValue
        }
    }
    
    open override var canBecomeFirstResponder: Bool {
        false
    }
    
    open var pasteActionTitle: String {
        get {
            pinView.pasteActionTitle
        }
        
        set {
            pinView.pasteActionTitle = newValue
        }
    }
    
    // MARK: - UIKeyInput
    
    open var hasText: Bool {
        pinView.hasText
    }
    
    open var autocapitalizationType: UITextAutocapitalizationType {
        get {
            pinView.autocapitalizationType
        }
        
        set {
            pinView.autocapitalizationType = newValue
        }
    }
    
    open var autocorrectionType: UITextAutocorrectionType {
        get {
            pinView.autocorrectionType
        }
        
        set {
            pinView.autocorrectionType = newValue
        }
    }
    
    open var spellCheckingType: UITextSpellCheckingType {
        get {
            pinView.spellCheckingType
        }
        
        set {
            pinView.spellCheckingType = newValue
        }
    }
    
    open var smartQuotesType: UITextSmartQuotesType {
        get {
            pinView.smartQuotesType
        }
        
        set {
            pinView.smartQuotesType = newValue
        }
    }
    
    open var smartDashesType: UITextSmartDashesType {
        get {
            pinView.smartDashesType
        }
        
        set {
            pinView.smartDashesType = newValue
        }
    }
    
    open var smartInsertDeleteType: UITextSmartInsertDeleteType {
        get {
            pinView.smartInsertDeleteType
        }
        
        set {
            pinView.smartInsertDeleteType = newValue
        }
    }
    
    open var keyboardType: UIKeyboardType {
        get {
            pinView.keyboardType
        }
        
        set {
            pinView.keyboardType = newValue
        }
    }
    
    open var keyboardAppearance: UIKeyboardAppearance {
        get {
            pinView.keyboardAppearance
        }
        
        set {
            pinView.keyboardAppearance = newValue
        }
    }
    
    open var returnKeyType: UIReturnKeyType {
        get {
            pinView.returnKeyType
        }
        
        set {
            pinView.returnKeyType = newValue
        }
    }
    
    open var enablesReturnKeyAutomatically: Bool {
        get {
            pinView.enablesReturnKeyAutomatically
        }
        
        set {
            pinView.enablesReturnKeyAutomatically = newValue
        }
    }
    
    open var isSecureTextEntry: Bool {
        get {
            pinView.isSecureTextEntry
        }
        
        set {
            pinView.isSecureTextEntry = newValue
        }
    }
    
    open var textContentType: UITextContentType! {
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
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        pinView.canPerformAction(action, withSender: sender)
    }
    
    open override func paste(_ sender: Any?) {
        pinView.paste(sender)
    }
    
    // MARK: - UIKeyInput
    
    open func insertText(_ text: String) {
        pinView.insertText(text)
    }
    
    open func deleteBackward() {
        pinView.deleteBackward()
    }
    
    // MARK: - UIResponder
    
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        pinView.becomeFirstResponder()
    }
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        pinView.resignFirstResponder()
    }
        
    // MARK: - UIEditMenuInteractionDelegate
    
    open func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        menuFor configuration: UIEditMenuConfiguration,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        pinView.editMenuInteraction(interaction, menuFor: configuration, suggestedActions: suggestedActions)
    }
    
    open func setText(_ text: String?) {
        pinView.setText(text)
    }
    
    open func initialConfiguration() {
        addSubview(pinView)
        
        // Make sure the view’s translatesAutoresizingMaskIntoConstraints is set to false
        pinView.translatesAutoresizingMaskIntoConstraints = false

        // Pin all edges of the `pinView` to the superview's edges
        NSLayoutConstraint.activate([
            pinView.topAnchor.constraint(equalTo: self.topAnchor),
            pinView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            pinView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            pinView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
}
