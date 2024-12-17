//
//  PinCodeInputView.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

import UIKit

@MainActor
open class PinCodeInputView<T: UIView & PinCodeItemViewType & PinCodeItemLayoutConfigurable & PinCodeItemAppearanceConfigurable>: UIView, UIKeyInput, @preconcurrency UIEditMenuInteractionDelegate {
    
    // MARK: - Internal types
    
    public enum ViewState {
        case disabled
        case normal
        case error
    }
    
    // MARK: - Properties(public)
    
    public var onPinValueChanged: PinCodeTextAction?
    public var onPinViewEnteredFully: PinCodeTextAction?
    public var onBecomeFirstResponder: PinCodeEmptyAction?
    public var onResignFirstResponder: PinCodeEmptyAction?
    
    public var text: String {
        charactersArray
            .compactMap({ $0 })
            .map({ String($0) })
            .joined()
    }
    
    open var config: PinViewConfig = PinViewConfig() {
        didSet {
            configureView()
        }
    }
    
    open var viewState: ViewState = .normal {
        didSet {
            updateSubviewStates()
        }
    }
    
    open var layoutConfig: T.LayoutConfig = T.LayoutConfig.defaultValue {
        didSet {
            itemViews.forEach({ $0.layoutConfig = layoutConfig })
        }
    }
    
    open var appearanceConfig: T.AppearanceConfig = T.AppearanceConfig.defaultValue {
        didSet {
            itemViews.forEach({ $0.appearanceConfig = appearanceConfig })
        }
    }
    
    open override var canBecomeFirstResponder: Bool {
        viewState != .disabled
    }
    
    open var pasteActionTitle: String = "Paste"
    
    // MARK: - UIKeyInput
    
    open var hasText: Bool {
        !text.isEmpty
    }
    
    open var autocapitalizationType: UITextAutocapitalizationType = .none
    open var autocorrectionType: UITextAutocorrectionType = .no
    open var spellCheckingType: UITextSpellCheckingType = .no
    open var smartQuotesType: UITextSmartQuotesType = .no
    open var smartDashesType: UITextSmartDashesType = .no
    open var smartInsertDeleteType: UITextSmartInsertDeleteType = .no
    open var keyboardType: UIKeyboardType = .numberPad
    open var keyboardAppearance: UIKeyboardAppearance = .default
    open var returnKeyType: UIReturnKeyType = .done
    open var enablesReturnKeyAutomatically: Bool = true
    open var isSecureTextEntry: Bool = false
    open var textContentType: UITextContentType! = .oneTimeCode
    
    // MARK: - Properties(private)
    
    private var activeItemIndex: Int? {
        didSet {
            debugPrint(activeItemIndex)
        }
    }
    
    private var charactersArray: [Character?] = []
    
    private var itemViews: [T] {
        containerStackView.arrangedSubviews.compactMap({ $0 as? T })
    }
    
    private lazy var containerStackView: UIStackView = {
        let view = UIStackView()
        return view
    }()
    
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
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return UIPasteboard.general.hasStrings
        }
        else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    open override func paste(_ sender: Any?) {
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
    
    open func insertText(_ text: String) {
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
    
    open func deleteBackward() {
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
    open override func becomeFirstResponder() -> Bool {
        debugPrint("Inner become first responder", "***")

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
    open override func resignFirstResponder() -> Bool {
        debugPrint("Inner resign first responder", "***")

        activeItemIndex = nil
        updateSubviewStates()
        
        onResignFirstResponder?()
        
        return super.resignFirstResponder()
    }
        
    // MARK: - UIEditMenuInteractionDelegate
    
    open func editMenuInteraction(
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
    
    open func setText(_ text: String?) {
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
        // Disable autoresizing mask translation for Auto Layout
        containerStackView.translatesAutoresizingMaskIntoConstraints = false

        // Remove any existing constraints on containerStackView
        NSLayoutConstraint.deactivate(containerStackView.constraints)

        addSubview(containerStackView)
        
        // Pin containerStackView top and bottom to the view’s edges
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        if config.isContentCentered {
            containerStackView.distribution = .fill
            containerStackView.spacing = config.containerSpacing
            
            // Center horizontally and allow flexible left/right constraints
            NSLayoutConstraint.activate([
                containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
                containerStackView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor),
                containerStackView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor)
            ])
        } else {
            containerStackView.distribution = .equalSpacing
            
            // Pin left and right to the view’s edges
            NSLayoutConstraint.activate([
                containerStackView.leftAnchor.constraint(equalTo: leftAnchor),
                containerStackView.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        }
    }
    
    private func configureSubviews() {
        containerStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
                
        for index in 0..<config.pinLength {
            let view = T()
                        
            view.onViewTapped = { [weak self] in
                debugPrint("On view tapped")
                self?.activeItemIndex = index
                self?.becomeFirstResponder()
            }
            
            view.translatesAutoresizingMaskIntoConstraints = false

            // Add width and height constraints to maintain a 1:1 aspect ratio
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalTo: view.widthAnchor)
            ])
            
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
