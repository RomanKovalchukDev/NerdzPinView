//
//  NerdzUnderlinePinView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 17.12.2024.
//

import UIKit
import SwiftUI

/// A SwiftUI wrapper around ``DesignableUnderlinedPinInputView`` for underlined pin entry.
///
/// It bridges the UIKit input into SwiftUI through `UIViewRepresentable`, binding
/// the entered ``text``, the ``viewState``, and the keyboard focus. Styling is
/// supplied through the item and view configuration parameters of ``init(text:viewState:isFocused:onPinViewEnteredFully:autocapitalizationType:autocorrectionType:spellCheckingType:smartQuotesType:smartDashesType:smartInsertDeleteType:keyboardType:keyboardAppearance:returnKeyType:enablesReturnKeyAutomatically:isSecureTextEntry:textContentType:config:itemsLayoutConfig:itemsAppearanceConfig:)``.
public struct NerdzUnderlinePinView: UIViewRepresentable {

    /// The overall state of the underlying pin input.
    public typealias ViewState = DesignableUnderlinedPinInputView.PinViewType.ViewState

    /// The behavior and layout configuration of the underlying pin input.
    public typealias ViewConfig = DesignableUnderlinedPinInputView.PinViewType.PinViewConfig

    /// The currently entered value.
    @Binding public var text: String

    /// The overall state of the input.
    @Binding public var viewState: ViewState

    /// The keyboard focus state that drives first responder status.
    @FocusState.Binding public var isFocused: Bool

    /// A closure invoked once every item has been filled.
    public var onPinViewEnteredFully: PinCodeTextAction?

    /// The autocapitalization style for the keyboard.
    public var autocapitalizationType: UITextAutocapitalizationType

    /// The autocorrection behavior for the keyboard.
    public var autocorrectionType: UITextAutocorrectionType

    /// The spell checking behavior for the keyboard.
    public var spellCheckingType: UITextSpellCheckingType

    /// The smart quotes behavior for the keyboard.
    public var smartQuotesType: UITextSmartQuotesType

    /// The smart dashes behavior for the keyboard.
    public var smartDashesType: UITextSmartDashesType

    /// The smart insert and delete behavior for the keyboard.
    public var smartInsertDeleteType: UITextSmartInsertDeleteType

    /// The keyboard type presented for input.
    public var keyboardType: UIKeyboardType

    /// The appearance of the keyboard.
    public var keyboardAppearance: UIKeyboardAppearance

    /// The title of the keyboard return key.
    public var returnKeyType: UIReturnKeyType

    /// A Boolean value indicating whether the return key is enabled only when there is text.
    public var enablesReturnKeyAutomatically: Bool

    /// A Boolean value indicating whether entered characters are masked.
    public var isSecureTextEntry: Bool

    /// The semantic meaning of the text, used for autofill.
    public var textContentType: UITextContentType!

    private let config: DesignableUnderlinedPinInputView.PinViewType.PinViewConfig
    private let itemsLayoutConfig: UnderlineItemView.LayoutConfig
    private let itemsAppearanceConfig: UnderlineItemView.AppearanceConfig

    /// Creates an underlined pin view.
    ///
    /// - Parameters:
    ///   - text: A binding to the entered value.
    ///   - viewState: A binding to the overall input state.
    ///   - isFocused: A focus binding that drives first responder status.
    ///   - onPinViewEnteredFully: A closure invoked once every item has been filled.
    ///   - autocapitalizationType: The autocapitalization style for the keyboard.
    ///   - autocorrectionType: The autocorrection behavior for the keyboard.
    ///   - spellCheckingType: The spell checking behavior for the keyboard.
    ///   - smartQuotesType: The smart quotes behavior for the keyboard.
    ///   - smartDashesType: The smart dashes behavior for the keyboard.
    ///   - smartInsertDeleteType: The smart insert and delete behavior for the keyboard.
    ///   - keyboardType: The keyboard type presented for input.
    ///   - keyboardAppearance: The appearance of the keyboard.
    ///   - returnKeyType: The title of the keyboard return key.
    ///   - enablesReturnKeyAutomatically: Whether the return key is enabled only when there is text.
    ///   - isSecureTextEntry: Whether entered characters are masked.
    ///   - textContentType: The semantic meaning of the text, used for autofill.
    ///   - config: The behavior and layout configuration of the pin input.
    ///   - itemsLayoutConfig: The layout configuration applied to every item view.
    ///   - itemsAppearanceConfig: The appearance configuration applied to every item view.
    public init(
        text: Binding<String>,
        viewState: Binding<ViewState>,
        isFocused: FocusState<Bool>.Binding,
        onPinViewEnteredFully: PinCodeTextAction? = nil,
        autocapitalizationType: UITextAutocapitalizationType = .none,
        autocorrectionType: UITextAutocorrectionType = .no,
        spellCheckingType: UITextSpellCheckingType = .no,
        smartQuotesType: UITextSmartQuotesType = .no,
        smartDashesType: UITextSmartDashesType = .no,
        smartInsertDeleteType: UITextSmartInsertDeleteType = .no,
        keyboardType: UIKeyboardType = .numberPad,
        keyboardAppearance: UIKeyboardAppearance = .default,
        returnKeyType: UIReturnKeyType = .done,
        enablesReturnKeyAutomatically: Bool = true,
        isSecureTextEntry: Bool = false,
        textContentType: UITextContentType! = .oneTimeCode,
        config: ViewConfig = .init(),
        itemsLayoutConfig: UnderlineItemView.LayoutConfig = .defaultValue,
        itemsAppearanceConfig: UnderlineItemView.AppearanceConfig = .defaultValue
    ) {
        self._text = text
        self._viewState = viewState
        self._isFocused = isFocused
        self.onPinViewEnteredFully = onPinViewEnteredFully
        self.autocapitalizationType = autocapitalizationType
        self.autocorrectionType = autocorrectionType
        self.spellCheckingType = spellCheckingType
        self.smartQuotesType = smartQuotesType
        self.smartDashesType = smartDashesType
        self.smartInsertDeleteType = smartInsertDeleteType
        self.keyboardType = keyboardType
        self.keyboardAppearance = keyboardAppearance
        self.returnKeyType = returnKeyType
        self.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        self.isSecureTextEntry = isSecureTextEntry
        self.textContentType = textContentType
        self.config = config
        self.itemsLayoutConfig = itemsLayoutConfig
        self.itemsAppearanceConfig = itemsAppearanceConfig
    }
    
    /// Creates and configures the backing UIKit view.
    ///
    /// - Parameter context: The representable context provided by SwiftUI.
    /// - Returns: A configured ``DesignableUnderlinedPinInputView``.
    public func makeUIView(context: Context) -> DesignableUnderlinedPinInputView {
        let view = DesignableUnderlinedPinInputView()
        
        updateKitView(view: view)
        
        view.onPinValueChanged = { text in
            self.text = text
        }
        
        view.onPinViewEnteredFully = { text in
            self.onPinViewEnteredFully?(text)
        }
            
        return view
    }
    
    /// Applies the current bindings and configuration to the backing UIKit view.
    ///
    /// - Parameters:
    ///   - uiView: The backing view to update.
    ///   - context: The representable context provided by SwiftUI.
    public func updateUIView(_ uiView: DesignableUnderlinedPinInputView, context: Context) {
        updateKitView(view: uiView)
        
        if isFocused && uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
        else if !isFocused && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }
    
    private func updateKitView(view: DesignableUnderlinedPinInputView) {
        view.setText(text)
        view.viewState = viewState
        view.config = config
        view.layoutConfig = itemsLayoutConfig
        view.appearanceConfig = itemsAppearanceConfig

        view.autocapitalizationType = autocapitalizationType
        view.autocorrectionType = autocorrectionType
        view.spellCheckingType = spellCheckingType
        view.smartQuotesType = smartQuotesType
        view.smartDashesType = smartDashesType
        view.smartInsertDeleteType = smartInsertDeleteType
        view.keyboardType = keyboardType
        view.keyboardAppearance = keyboardAppearance
        view.returnKeyType = returnKeyType
        view.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        view.isSecureTextEntry = isSecureTextEntry
        view.textContentType = textContentType
    }
}

