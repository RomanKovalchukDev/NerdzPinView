//
//  PinCodeInputView.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

import UIKit

@MainActor
public final class PinCodeInputView<T: UIView & PinCodeItemViewType & PinCodeItemLayoutConfigurable & PinCodeItemAppearanceConfigurable>: UIView, UIKeyInput, @preconcurrency UIEditMenuInteractionDelegate {
    
    // MARK: - Internal types
    
    public enum ViewState {
        case disabled
        case normal
        case error
    }
    
    // MARK: - Properties(public)
    
    public var onPinViewEnteredFully: PinCodeTextAction?
    public var onPinValueChanged: PinCodeTextAction?
    public var onBecomeFirstResponder: PinCodeEmptyAction?
    public var onResignFirstResponder: PinCodeEmptyAction?
    
    public var text: String {
        charactersArray
            .compactMap({ $0 })
            .map({ String($0) })
            .joined()
    }
    
    public var config: PinViewConfig = PinViewConfig() {
        didSet {
            configureView()
        }
    }
    
    public var viewState: ViewState = .normal {
        didSet {
            updateSubviewStates()
        }
    }
    
    public var layoutConfig: T.LayoutConfig = T.LayoutConfig.defaultValue {
        didSet {
            itemViews.forEach({ $0.layoutConfig = layoutConfig })
        }
    }
    
    public var appearanceConfig: T.AppearanceConfig = T.AppearanceConfig.defaultValue {
        didSet {
            itemViews.forEach({ $0.appearanceConfig = appearanceConfig })
        }
    }
    
    public override var canBecomeFirstResponder: Bool {
        viewState != .disabled
    }
    
    public var pasteActionTitle: String = "Paste"
    
    // MARK: - UIKeyInput
    
    public var hasText: Bool {
        !text.isEmpty
    }
    
    public var autocapitalizationType: UITextAutocapitalizationType = .none
    public var autocorrectionType: UITextAutocorrectionType = .no
    public var spellCheckingType: UITextSpellCheckingType = .no
    public var smartQuotesType: UITextSmartQuotesType = .no
    public var smartDashesType: UITextSmartDashesType = .no
    public var smartInsertDeleteType: UITextSmartInsertDeleteType = .no
    public var keyboardType: UIKeyboardType = .numberPad
    public var keyboardAppearance: UIKeyboardAppearance = .default
    public var returnKeyType: UIReturnKeyType = .done
    public var enablesReturnKeyAutomatically: Bool = true
    public var isSecureTextEntry: Bool = false
    public var textContentType: UITextContentType! = .oneTimeCode
    
    // MARK: - Properties(private)
    
    private var activeItemIndex: Int?
        
    private var charactersArray: [Character?] = []
    
    private lazy var containerStackView: UIStackView = {
        let view = UIStackView()
        return view
    }()
    
    private var itemViews: [T] {
        containerStackView.arrangedSubviews.compactMap({ $0 as? T })
    }
            
    private lazy var editMenuInteraction: UIEditMenuInteraction = {
        let interaction = UIEditMenuInteraction(delegate: self)
        return interaction
    }()
    
    private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        gesture.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        return gesture
    }()
    
    // MARK: - IBActions
    
    @IBAction private func didLongPress(_ recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: containerStackView)
        let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)

        editMenuInteraction.presentEditMenu(with: configuration)
    }
    
    // MARK: - Life cycle
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureView()
    }
    
    // MARK: - Methods(public)
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return  UIPasteboard.general.hasStrings
        }
        else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    public override func paste(_ sender: Any?) {
        if let string = UIPasteboard.general.string {
            let pin: [Character] = Array(string)
            
            guard !pin.isEmpty else {
                return
            }
            
            var pasteboardPinIterator: Int = 0
            for index in (activeItemIndex ?? .zero)..<config.pinLength {
                pasteboardPinIterator += 1
                charactersArray[index] = pin[pasteboardPinIterator]
            }
            
            updateSubviewStates()
            updateAllSubviewValues()
        }
    }
    
    // MARK: - UIKeyInput
    
    public func insertText(_ text: String) {
        if text == "\n" {
            // Return key pressed
            if config.shouldResignFirstResponderOnReturn {
                resignFirstResponder()
            }
        }
        else {
            if let activeItemIndex {
                charactersArray[activeItemIndex] = text.first
                itemViews[activeItemIndex].setCharacter(text.first, animated: true)

                onPinValueChanged?(self.text)
                
                let nextItemIndex = activeItemIndex + 1
                
                if nextItemIndex < config.pinLength {
                    self.activeItemIndex = nextItemIndex
                }
                else {
                    // Handle finish
                    
                    if config.shouldResignFirstResponderOnEnd {
                        resignFirstResponder()
                    }
                }
                
                if self.text.count == config.pinLength {
                    onPinViewEnteredFully?(self.text)
                }
            }
        }
        
        updateSubviewStates()
    }
    
    public func deleteBackward() {
        if let activeItemIndex {
            let oldValue = charactersArray[activeItemIndex]
            
            charactersArray[activeItemIndex] = nil
            itemViews[activeItemIndex].setCharacter(nil, animated: false)
            
            if config.shouldMoveToPreviousOnDelete || oldValue == nil {
                let nextItemIndex = activeItemIndex - 1
                
                if nextItemIndex >= 0 {
                    self.activeItemIndex = nextItemIndex
                    self.updateSubviewStates()
                }
            }
            
            onPinValueChanged?(self.text)
        }
    }
    
    // MARK: - UIResponder
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        // If become first responder was called without taping on specific item - select first one
        if activeItemIndex == nil {
            activeItemIndex = .zero
        }
        
        // If view was in error state - make it normal
        if viewState == .error {
            viewState = .normal
        }
                
        updateSubviewStates()
        
        onBecomeFirstResponder?()
        
        return super.becomeFirstResponder()
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        activeItemIndex = nil
        updateSubviewStates()
        
        onResignFirstResponder?()
        
        return super.resignFirstResponder()
    }
        
    // MARK: - UIEditMenuInteractionDelegate
    
    public func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        menuFor configuration: UIEditMenuConfiguration,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        guard UIPasteboard.general.hasStrings else {
            return nil
        }
        
        let pasteAction = UIAction(title: pasteActionTitle) { [weak self] _ in
            self?.paste(self)
        }
        
        return UIMenu(title: "", children: [pasteAction])
    }
    
    public func setText(_ text: String?) {
        let pin: [Character] = Array(text ?? "")
        
        for index in (0..<config.pinLength) {
            if index < pin.count {
                charactersArray[index] = pin[index]
            }
            else {
                charactersArray[index] = nil
            }
        }
        
        updateAllSubviewValues()
    }
    
    // MARK: - Methods(private)
    
    private func configureView() {
        initialViewLayout()
        
        configureSubviews()
        
        containerStackView.addInteraction(editMenuInteraction)
        containerStackView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    private func initialViewLayout() {
        containerStackView.constraints.deActivate()
        
        addSubview(containerStackView)
        containerStackView.topToSuperview()
        containerStackView.bottomToSuperview()
        
        containerStackView.leftToSuperview(relation: config.isContentCentered ? .equalOrGreater : .equal)
        containerStackView.rightToSuperview(relation: config.isContentCentered ? .equalOrLess : .equal)
        
        if config.isContentCentered {
            containerStackView.distribution = .fill
            containerStackView.spacing = config.containerSpacing
            containerStackView.centerXToSuperview()
        }
        else {
            containerStackView.distribution = .equalSpacing
        }
    }
    
    private func configureSubviews() {
        containerStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
                
        for index in 0..<config.pinLength {
            let view = T()
                        
            view.onViewTapped = { [weak self] in
                self?.activeItemIndex = index
                self?.becomeFirstResponder()
            }
            
            view.aspectRatio(1)
            view.layoutConfig = layoutConfig
            view.appearanceConfig = appearanceConfig
            view.placeholderCharacter = config.placeholderCharacter
            view.secureTextCharacter = config.secureTextCharacter
            view.secureTextDelay = config.secureTextDelay
                                                
            charactersArray.append(nil)
            containerStackView.addArrangedSubview(view)
        }
    }
    
    private func updateAllSubviewValues() {
        for (index, itemView) in itemViews.enumerated() {
            itemView.setCharacter(charactersArray[index], animated: false)
        }
    }
    
    private func updateSubviewStates() {
        for (index, itemView) in itemViews.enumerated() {
            itemView.shouldSecureText = isSecureTextEntry
            
            switch viewState {
            case .disabled:
                itemView.viewState = .disabled
                
            case .normal:
                itemView.viewState = index == activeItemIndex ? .active : .normal
                
            case .error:
                itemView.viewState = .error
            }
        }
    }
}
