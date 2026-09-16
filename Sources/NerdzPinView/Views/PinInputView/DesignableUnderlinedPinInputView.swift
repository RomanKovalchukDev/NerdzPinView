//
//  DesignableUnderlinedPinInputView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 15.12.2024.
//

import UIKit

/// A ready to use underlined pin input that wraps and pre-styles a ``PinCodeInputView``.
///
/// It exposes the underlying ``pinView`` along with forwarding properties for
/// text, configuration, state, and keyboard traits, and applies a default
/// underlined appearance. Subclass it to customize the preset styling, or use
/// ``NerdzUnderlinePinView`` to embed it in SwiftUI.
@MainActor
open class DesignableUnderlinedPinInputView: UIView, UIKeyInput, @preconcurrency UIEditMenuInteractionDelegate {

    // MARK: - Aliases

    /// The concrete ``PinCodeInputView`` specialization backing this view.
    public typealias PinViewType = PinCodeInputView<UnderlineItemView>

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

    /// The backing pin input, pre-configured with the default underlined styling.
    open var pinView: PinViewType = {
        let view = PinViewType()
        view.config = PinViewType.PinViewConfig(pinLength: 6, isContentCentered: false)
        view.layoutConfig = UnderlineItemView.LayoutConfig(cornerRadius: .zero)
        view.appearanceConfig = UnderlineItemView.AppearanceConfig(
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
    
    /// A closure invoked once every item has been filled.
    public var onPinViewEnteredFully: PinCodeTextAction? {
        get {
            pinView.onPinViewEnteredFully
        }

        set {
            pinView.onPinViewEnteredFully = newValue
        }
    }

    /// A closure invoked whenever the entered value changes.
    public var onPinValueChanged: PinCodeTextAction? {
        get {
            pinView.onPinValueChanged
        }

        set {
            pinView.onPinValueChanged = newValue
        }
    }

    /// A closure invoked when the input becomes first responder.
    public var onBecomeFirstResponder: PinCodeEmptyAction? {
        get {
            pinView.onBecomeFirstResponder
        }

        set {
            pinView.onBecomeFirstResponder = newValue
        }
    }

    /// A closure invoked when the input resigns first responder.
    public var onResignFirstResponder: PinCodeEmptyAction? {
        get {
            pinView.onResignFirstResponder
        }

        set {
            pinView.onResignFirstResponder = newValue
        }
    }

    /// The currently entered value.
    public var text: String {
        pinView.text
    }

    /// The behavior and layout configuration of the underlying pin input.
    open var config: PinViewType.PinViewConfig {
        get {
            pinView.config
        }
        
        set {
            pinView.config = newValue
        }
    }
    
    /// The overall state of the underlying pin input.
    open var viewState: PinViewType.ViewState {
        get {
            pinView.viewState
        }

        set {
            pinView.viewState = newValue
        }
    }

    /// The layout configuration applied to every item view.
    open var layoutConfig: UnderlineItemView.LayoutConfig {
        get {
            pinView.layoutConfig
        }

        set {
            pinView.layoutConfig = newValue
        }
    }

    /// The appearance configuration applied to every item view.
    open var appearanceConfig: UnderlineItemView.AppearanceConfig {
        get {
            pinView.appearanceConfig
        }

        set {
            pinView.appearanceConfig = newValue
        }
    }

    /// A Boolean value indicating whether this wrapper can become first responder. Always `false`, since the ``pinView`` holds first responder.
    open override var canBecomeFirstResponder: Bool {
        false
    }

    // MARK: - UIKeyInput

    /// A Boolean value indicating whether the input contains any characters.
    open var hasText: Bool {
        pinView.hasText
    }

    /// The autocapitalization style for the keyboard.
    open var autocapitalizationType: UITextAutocapitalizationType {
        get {
            pinView.autocapitalizationType
        }
        
        set {
            pinView.autocapitalizationType = newValue
        }
    }
    
    /// The autocorrection behavior for the keyboard.
    open var autocorrectionType: UITextAutocorrectionType {
        get {
            pinView.autocorrectionType
        }

        set {
            pinView.autocorrectionType = newValue
        }
    }

    /// The spell checking behavior for the keyboard.
    open var spellCheckingType: UITextSpellCheckingType {
        get {
            pinView.spellCheckingType
        }

        set {
            pinView.spellCheckingType = newValue
        }
    }

    /// The smart quotes behavior for the keyboard.
    open var smartQuotesType: UITextSmartQuotesType {
        get {
            pinView.smartQuotesType
        }

        set {
            pinView.smartQuotesType = newValue
        }
    }

    /// The smart dashes behavior for the keyboard.
    open var smartDashesType: UITextSmartDashesType {
        get {
            pinView.smartDashesType
        }

        set {
            pinView.smartDashesType = newValue
        }
    }

    /// The smart insert and delete behavior for the keyboard.
    open var smartInsertDeleteType: UITextSmartInsertDeleteType {
        get {
            pinView.smartInsertDeleteType
        }

        set {
            pinView.smartInsertDeleteType = newValue
        }
    }

    /// The keyboard type presented for input.
    open var keyboardType: UIKeyboardType {
        get {
            pinView.keyboardType
        }

        set {
            pinView.keyboardType = newValue
        }
    }

    /// The appearance of the keyboard.
    open var keyboardAppearance: UIKeyboardAppearance {
        get {
            pinView.keyboardAppearance
        }

        set {
            pinView.keyboardAppearance = newValue
        }
    }

    /// The title of the keyboard return key.
    open var returnKeyType: UIReturnKeyType {
        get {
            pinView.returnKeyType
        }

        set {
            pinView.returnKeyType = newValue
        }
    }

    /// A Boolean value indicating whether the return key is enabled only when there is text.
    open var enablesReturnKeyAutomatically: Bool {
        get {
            pinView.enablesReturnKeyAutomatically
        }

        set {
            pinView.enablesReturnKeyAutomatically = newValue
        }
    }

    /// A Boolean value indicating whether entered characters are masked.
    open var isSecureTextEntry: Bool {
        get {
            pinView.isSecureTextEntry
        }

        set {
            pinView.isSecureTextEntry = newValue
        }
    }

    /// The semantic meaning of the text, used for autofill.
    open var textContentType: UITextContentType! {
        get {
            pinView.textContentType
        }

        set {
            pinView.textContentType = newValue
        }
    }

    // MARK: - Life cycle

    /// Creates the view programmatically with the given frame.
    ///
    /// - Parameter frame: The initial frame rectangle for the view.
    public override init(frame: CGRect) {
        super.init(frame: frame)

        initialConfiguration()
    }

    /// Creates the view from data in the given unarchiver.
    ///
    /// - Parameter coder: The unarchiver providing the encoded view data.
    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialConfiguration()
    }

    // MARK: - Methods(public)

    /// Reports whether the wrapped input can perform a given action.
    ///
    /// - Parameters:
    ///   - action: The selector describing the action to evaluate.
    ///   - sender: The object requesting the action.
    /// - Returns: `true` if the action is supported in the current context.
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        pinView.canPerformAction(action, withSender: sender)
    }

    /// Pastes the pasteboard string into the wrapped input.
    ///
    /// - Parameter sender: The object requesting the paste.
    open override func paste(_ sender: Any?) {
        pinView.paste(sender)
    }

    // MARK: - UIKeyInput

    /// Inserts text into the wrapped input.
    ///
    /// - Parameter text: The text to insert.
    open func insertText(_ text: String) {
        pinView.insertText(text)
    }

    /// Deletes the character before the active position in the wrapped input.
    open func deleteBackward() {
        pinView.deleteBackward()
    }

    // MARK: - UIResponder

    /// Makes the wrapped input active.
    ///
    /// - Returns: `true` if the input became first responder.
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        pinView.becomeFirstResponder()
    }

    /// Deactivates the wrapped input.
    ///
    /// - Returns: `true` if the input resigned first responder.
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        pinView.resignFirstResponder()
    }

    // MARK: - UIEditMenuInteractionDelegate

    /// Forwards the edit menu request to the wrapped input.
    ///
    /// - Parameters:
    ///   - interaction: The edit menu interaction requesting the menu.
    ///   - configuration: The configuration for the menu being presented.
    ///   - suggestedActions: The system suggested menu elements.
    /// - Returns: The menu provided by the wrapped input, or `nil` when there is nothing to paste.
    open func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        menuFor configuration: UIEditMenuConfiguration,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        pinView.editMenuInteraction(interaction, menuFor: configuration, suggestedActions: suggestedActions)
    }

    /// Replaces the entire entered value of the wrapped input.
    ///
    /// - Parameter text: The new value, or `nil` to clear the input.
    open func setText(_ text: String?) {
        pinView.setText(text)
    }

    /// Adds the wrapped ``pinView`` as a subview and pins it to the bounds.
    open func initialConfiguration() {
        addAndFillSubview(pinView, directionalLayoutMargins: .zero)
    }
}
