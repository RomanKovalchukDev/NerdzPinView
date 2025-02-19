//
//  NerdzUnderlinePinView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 17.12.2024.
//

import UIKit
import SwiftUI

public struct NerdzUnderlinePinView: UIViewRepresentable {
    
    public typealias ViewState = DesignableUnderlinedPinInputView.PinViewType.ViewState
    public typealias ViewConfig = DesignableUnderlinedPinInputView.PinViewType.PinViewConfig
    
    @Binding public var text: String
    @Binding public var viewState: ViewState
    @FocusState.Binding public var isFocused: Bool
    
    public var onPinViewEnteredFully: PinCodeTextAction?
    public var autocapitalizationType: UITextAutocapitalizationType
    public var autocorrectionType: UITextAutocorrectionType
    public var spellCheckingType: UITextSpellCheckingType
    public var smartQuotesType: UITextSmartQuotesType
    public var smartDashesType: UITextSmartDashesType
    public var smartInsertDeleteType: UITextSmartInsertDeleteType
    public var keyboardType: UIKeyboardType
    public var keyboardAppearance: UIKeyboardAppearance
    public var returnKeyType: UIReturnKeyType
    public var enablesReturnKeyAutomatically: Bool
    public var isSecureTextEntry: Bool
    public var textContentType: UITextContentType!
    
    private let config: DesignableUnderlinedPinInputView.PinViewType.PinViewConfig
    private let itemsLayutConfig: UnderlineItemView.LayoutConfig
    private let itemsAppearanceConfig: UnderlineItemView.AppearanceConfig
    
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
        itemsLayutConfig: UnderlineItemView.LayoutConfig = .defaultValue,
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
        self.itemsLayutConfig = itemsLayutConfig
        self.itemsAppearanceConfig = itemsAppearanceConfig
    }
    
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

