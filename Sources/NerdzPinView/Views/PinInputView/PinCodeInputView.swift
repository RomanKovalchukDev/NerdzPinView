//
//  PinCodeInputView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

import UIKit

/// A view that can act as one item cell of a ``PinCodeInputView``.
///
/// Any conforming type is a `UIView` that also renders a pin character
/// (``PinCodeItemViewType``) and is both layout and appearance configurable.
public typealias PinCodeItemView = UIView & PinCodeItemViewType & ItemViewLayoutConfigurable & ItemViewAppearanceConfigurable

/// A generic pin code input made of individually tappable item views.
///
/// The container manages one item view of type `T` per character, tracks the
/// active cell, and forwards keyboard input, pasting, and first responder
/// changes. It reports edits through ``onPinValueChanged`` and completion
/// through ``onPinViewEnteredFully``. Use ``DesignableBorderedPinInputView`` or
/// ``DesignableUnderlinedPinInputView`` for ready to use configurations.
@MainActor
public class PinCodeInputView<T: PinCodeItemView>: UIView, UIKeyInput, @preconcurrency UIEditMenuInteractionDelegate {

    // MARK: - Internal types

    /// The overall state of the pin input.
    public enum ViewState {
        /// The input cannot receive text.
        case disabled

        /// The input is idle and accepts text.
        case normal

        /// The input is presenting an error and highlights every item accordingly.
        case error
    }

    /// Behavior and layout options for a ``PinCodeInputView``.
    public struct PinViewConfig: Equatable {
        /// The number of characters the input accepts.
        public var pinLength: Int

        /// The placeholder character shown in empty items, or `nil` for none.
        public var placeholderCharacter: Character?

        /// The delay before an entered character is masked when secure entry is on.
        public var secureTextDelay: TimeInterval

        /// The character used to mask entered values when secure entry is on.
        public var secureTextCharacter: Character

        /// The title of the paste action shown in the edit menu.
        public var pasteActionTitle: String

        /// The minimum press duration that triggers the paste gesture.
        public var pasteGestureMinDuration: TimeInterval

        /// A Boolean value indicating whether the items are centered rather than stretched to fill the width.
        public var isContentCentered: Bool

        /// The spacing between item views.
        public var containerSpacing: CGFloat

        /// A Boolean value indicating whether deleting moves the active item back to the previous cell.
        public var shouldMoveToPreviousOnDelete: Bool

        /// A Boolean value indicating whether the input resigns first responder once fully entered.
        public var shouldResignFirstResponderOnEnd: Bool

        /// A Boolean value indicating whether the input resigns first responder when the return key is pressed.
        public var shouldResignFirstResponderOnReturn: Bool

        /// Creates a pin input configuration.
        ///
        /// - Parameters:
        ///   - pinLength: The number of characters the input accepts.
        ///   - placeholderCharacter: The placeholder character shown in empty items, or `nil` for none.
        ///   - secureTextCharacter: The character used to mask entered values when secure entry is on.
        ///   - secureTextDelay: The delay before an entered character is masked when secure entry is on.
        ///   - pasteActionTitle: The title of the paste action shown in the edit menu.
        ///   - pasteGestureMinDuration: The minimum press duration that triggers the paste gesture.
        ///   - isContentCentered: Whether the items are centered rather than stretched to fill the width.
        ///   - containerSpacing: The spacing between item views.
        ///   - shouldMoveToPreviousOnDelete: Whether deleting moves the active item back to the previous cell.
        ///   - shouldResignFirstResponderOnEnd: Whether the input resigns first responder once fully entered.
        ///   - shouldResignFirstResponderOnReturn: Whether the input resigns first responder when the return key is pressed.
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

    /// A closure invoked whenever the entered value changes.
    public var onPinValueChanged: PinCodeTextAction?

    /// A closure invoked once every item has been filled.
    public var onPinViewEnteredFully: PinCodeTextAction?

    /// A closure invoked when the input becomes first responder.
    public var onBecomeFirstResponder: PinCodeEmptyAction?

    /// A closure invoked when the input resigns first responder.
    public var onResignFirstResponder: PinCodeEmptyAction?

    /// The currently entered value, concatenated from every filled item.
    public var text: String {
        charactersArray
            .compactMap({ $0 })
            .map({ String($0) })
            .joined()
    }

    /// The behavior and layout configuration. Assigning a new value rebuilds the item views.
    public var config: PinViewConfig = PinViewConfig() {
        didSet {
            guard oldValue != config else { return }
            configureView()
        }
    }

    /// The overall state of the input, propagated to every item view.
    public var viewState: ViewState = .normal {
        didSet {
            updateSubviewStates()
        }
    }

    /// The layout configuration applied to every item view.
    public var layoutConfig: T.LayoutConfig = T.LayoutConfig.defaultValue {
        didSet {
            itemViews.forEach({ $0.layoutConfig = layoutConfig })
        }
    }

    /// The appearance configuration applied to every item view.
    public var appearanceConfig: T.AppearanceConfig = T.AppearanceConfig.defaultValue {
        didSet {
            itemViews.forEach({ $0.appearanceConfig = appearanceConfig })
        }
    }

    /// A Boolean value indicating whether the input can become first responder. `false` while disabled.
    public override var canBecomeFirstResponder: Bool {
        viewState != .disabled
    }

    // MARK: - UIKeyInput

    /// A Boolean value indicating whether the input contains any characters.
    public var hasText: Bool {
        !text.isEmpty
    }

    /// The autocapitalization style for the keyboard.
    public var autocapitalizationType: UITextAutocapitalizationType = .none

    /// The autocorrection behavior for the keyboard.
    public var autocorrectionType: UITextAutocorrectionType = .no

    /// The spell checking behavior for the keyboard.
    public var spellCheckingType: UITextSpellCheckingType = .no

    /// The smart quotes behavior for the keyboard.
    public var smartQuotesType: UITextSmartQuotesType = .no

    /// The smart dashes behavior for the keyboard.
    public var smartDashesType: UITextSmartDashesType = .no

    /// The smart insert and delete behavior for the keyboard.
    public var smartInsertDeleteType: UITextSmartInsertDeleteType = .no

    /// The keyboard type presented for input.
    public var keyboardType: UIKeyboardType = .numberPad

    /// The appearance of the keyboard.
    public var keyboardAppearance: UIKeyboardAppearance = .default

    /// The title of the keyboard return key.
    public var returnKeyType: UIReturnKeyType = .done

    /// A Boolean value indicating whether the return key is enabled only when there is text.
    public var enablesReturnKeyAutomatically: Bool = true

    /// A Boolean value indicating whether entered characters are masked.
    public var isSecureTextEntry: Bool = false

    /// The semantic meaning of the text, used for autofill. Defaults to one-time code.
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
        
    /// Creates the input programmatically with the given frame.
    ///
    /// - Parameter frame: The initial frame rectangle for the view.
    public override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    /// Creates the input from data in the given unarchiver.
    ///
    /// - Parameter coder: The unarchiver providing the encoded view data.
    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureView()
    }

    // MARK: - Methods(public)

    /// Reports whether the input can perform a given action, enabling paste only when the pasteboard has text.
    ///
    /// - Parameters:
    ///   - action: The selector describing the action to evaluate.
    ///   - sender: The object requesting the action.
    /// - Returns: `true` if the action is supported in the current context.
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return UIPasteboard.general.hasStrings
        }
        else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    /// Pastes the pasteboard string into the items, starting at the active cell.
    ///
    /// - Parameter sender: The object requesting the paste.
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

    /// Inserts text at the active item and advances the active position.
    ///
    /// A newline is treated as a return key press and may resign first responder
    /// depending on ``PinViewConfig/shouldResignFirstResponderOnReturn``.
    ///
    /// - Parameter text: The text to insert. Only the first character is used per item.
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
    
    /// Clears the active item and, when configured, moves the active position to the previous cell.
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
    
    /// Makes the input active, selecting the first item when no specific cell was tapped.
    ///
    /// - Returns: `true` if the input became first responder.
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
    
    /// Deactivates the input and clears the active item selection.
    ///
    /// - Returns: `true` if the input resigned first responder.
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        activeItemIndex = nil
        updateSubviewStates()

        onResignFirstResponder?()

        return super.resignFirstResponder()
    }

    // MARK: - UIEditMenuInteractionDelegate

    /// Provides the edit menu, offering a paste action when the pasteboard has text.
    ///
    /// - Parameters:
    ///   - interaction: The edit menu interaction requesting the menu.
    ///   - configuration: The configuration for the menu being presented.
    ///   - suggestedActions: The system suggested menu elements.
    /// - Returns: A menu containing the paste action, or `nil` when there is nothing to paste.
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
    
    /// Replaces the entire entered value without triggering input callbacks.
    ///
    /// - Parameter text: The new value. Characters beyond the pin length are ignored, and a shorter or `nil` value clears the remaining items.
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
