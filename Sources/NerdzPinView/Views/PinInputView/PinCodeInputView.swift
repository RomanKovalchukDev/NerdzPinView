//
//  PinCodeInputView.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

import UIKit

public typealias PinCodeItemView = UIView & PinCodeItemViewType & ItemViewLayoutConfigurable & ItemViewAppearanceConfigurable

@MainActor
public class PinCodeInputView<T: PinCodeItemView>: UIView, UIKeyInput, @preconcurrency UIEditMenuInteractionDelegate {
    
    // MARK: - Internal types
    
    public enum ViewState {
        case disabled
        case normal
        case error
    }
    
    public struct PinViewConfig: Equatable {
        public var pinLength: Int
        public var placeholderCharacter: Character?
        
        public var secureTextDelay: TimeInterval
        public var secureTextCharacter: Character
        
        public var pasteActionTitle: String
        public var pasteGestureMinDuration: TimeInterval
        
        // If content is centered - stack view would take located in center of the view / otherwise would be stretched
        public var isContentCentered: Bool
        public var containerSpacing: CGFloat
        
        public var shouldMoveToPreviousOnDelete: Bool
        public var shouldResignFirstResponderOnEnd: Bool
        public var shouldResignFirstResponderOnReturn: Bool
        
        public init(
            pinLength: Int = 5,
            placeholderCharacter: Character? = nil,
            secureTextCharacter: Character = "*",
            secureTextDelay: TimeInterval = 0.8,
            pasteActionTitle: String = "Paste",
            pasteGestureMinDuration: TimeInterval = 0.2,
            isContentCentered: Bool = true,
            containerSpacing: CGFloat = 10,
            shouldMoveToPreviousOnDelete: Bool = true,
            shouldResignFirstResponderOnEnd: Bool = true,
            shouldResignFirstResponderOnReturn: Bool = false
        ) {
            self.pinLength = pinLength
            self.placeholderCharacter = placeholderCharacter
            self.secureTextCharacter = secureTextCharacter
            self.secureTextDelay = secureTextDelay
            self.pasteActionTitle = pasteActionTitle
            self.pasteGestureMinDuration = pasteGestureMinDuration
            self.isContentCentered = isContentCentered
            self.containerSpacing = containerSpacing
            self.shouldMoveToPreviousOnDelete = shouldMoveToPreviousOnDelete
            self.shouldResignFirstResponderOnEnd = shouldResignFirstResponderOnEnd
            self.shouldResignFirstResponderOnReturn = shouldResignFirstResponderOnReturn
        }
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
    
    public var config: PinViewConfig = PinViewConfig() {
        didSet {
            guard oldValue != config else { return }
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
    private var stackAnchorConstraints: [NSLayoutConstraint] = []
    private var hasConfiguredHierarchy: Bool = false
    
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
                if pasteboardPinIterator < pin.count {
                    charactersArray[index] = pin[pasteboardPinIterator]
                }
                
                pasteboardPinIterator += 1
            }
            
            activeItemIndex = min(pin.count, config.pinLength - 1)
            
            // Handle finish
            if config.shouldResignFirstResponderOnEnd && pin.count >= config.pinLength {
                resignFirstResponder()
            }
            
            if self.text.count == config.pinLength {
                onPinViewEnteredFully?(self.text)
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
            if let activeItemIndex, activeItemIndex >= .zero {
                if activeItemIndex < charactersArray.count {
                    charactersArray[activeItemIndex] = text.first
                }
                
                if activeItemIndex < itemViews.count {
                    itemViews[activeItemIndex].setCharacter(text.first, animated: true)
                }
                
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
        guard let activeItemIndex else {
            return
        }
        
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
    
    // MARK: - UIResponder
    
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
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
        
        let pasteAction = UIAction(title: config.pasteActionTitle) { [weak self] _ in
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
    }

    private func initialViewLayout() {
        containerStackView.translatesAutoresizingMaskIntoConstraints = false

        // One-time hierarchy/setup. Re-running addSubview, addInteraction and
        // addGestureRecognizer on every config change would otherwise stack up
        // duplicate interactions and recognizers.
        if !hasConfiguredHierarchy {
            addSubview(containerStackView)

            containerStackView.axis = .horizontal
            // Items are not forced to fill the cross axis — each item sizes itself
            // via its own constraints (square + capped to the stack height) and is
            // centered vertically when it has to shrink to fit the available width.
            containerStackView.alignment = .center

            containerStackView.addInteraction(editMenuInteraction)
            containerStackView.addGestureRecognizer(longPressGestureRecognizer)

            NSLayoutConstraint.activate([
                containerStackView.topAnchor.constraint(equalTo: topAnchor),
                containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])

            hasConfiguredHierarchy = true
        }

        containerStackView.spacing = config.containerSpacing
        // .equalSpacing in both branches keeps items at their natural square size
        // and absorbs leftover horizontal space into the inter-item gaps. With
        // .fill the stack would divide its width across N items, which can force
        // each item wider than the stack is tall and break the 1:1 constraint.
        containerStackView.distribution = .equalSpacing
        longPressGestureRecognizer.minimumPressDuration = config.pasteGestureMinDuration

        // Drop the previously installed horizontal anchors so that switching
        // between centered / non-centered modes does not leave both sets active.
        NSLayoutConstraint.deactivate(stackAnchorConstraints)
        stackAnchorConstraints.removeAll()

        if config.isContentCentered {
            stackAnchorConstraints = [
                containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
                containerStackView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor),
                containerStackView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor)
            ]
        }
        else {
            stackAnchorConstraints = [
                containerStackView.leftAnchor.constraint(equalTo: leftAnchor),
                containerStackView.rightAnchor.constraint(equalTo: rightAnchor)
            ]
        }

        NSLayoutConstraint.activate(stackAnchorConstraints)
    }
    
    private func configureSubviews() {
        charactersArray.removeAll()
        containerStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })

        var firstItemView: T?

        for index in 0..<config.pinLength {
            let view = T()

            view.onViewTapped = { [weak self] in
                guard let self else {
                    return
                }

                let firstEmpty = self.charactersArray.firstIndex(where: { $0 == nil }) ?? (self.config.pinLength - 1)
                self.activeItemIndex = min(index, firstEmpty)
                self.becomeFirstResponder()
            }

            view.translatesAutoresizingMaskIntoConstraints = false

            view.layoutConfig = layoutConfig
            view.appearanceConfig = appearanceConfig
            view.placeholderCharacter = config.placeholderCharacter
            view.secureTextCharacter = config.secureTextCharacter
            view.secureTextDelay = config.secureTextDelay

            charactersArray.append(nil)
            containerStackView.addArrangedSubview(view)

            // Square aspect, hard cap to stack height, and a high-priority preference
            // to be exactly stack height. The preference bends when the available width
            // can't fit N full-height squares, so constraints never become unsatisfiable.
            let aspect = view.heightAnchor.constraint(equalTo: view.widthAnchor)
            aspect.priority = .required

            let heightCap = view.heightAnchor.constraint(lessThanOrEqualTo: containerStackView.heightAnchor)
            heightCap.priority = .required

            let preferredHeight = view.heightAnchor.constraint(equalTo: containerStackView.heightAnchor)
            preferredHeight.priority = .defaultHigh

            NSLayoutConstraint.activate([aspect, heightCap, preferredHeight])

            // All items share the first item's width — keeps every cell identical
            // and prevents the stack from handing leftover space to one cell.
            if let firstItemView, view !== firstItemView {
                let equalWidth = view.widthAnchor.constraint(equalTo: firstItemView.widthAnchor)
                equalWidth.priority = .required
                equalWidth.isActive = true
            }
            else {
                firstItemView = view
            }
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
