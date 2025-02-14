//
//  PinCodeInputView.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

import UIKit

@MainActor
public class PinCodeInputView<T: UIView & PinCodeItemViewType & PinCodeItemLayoutConfigurable & PinCodeItemAppearanceConfigurable>:
    UIView,
    UIKeyInput,
    @preconcurrency UIEditMenuInteractionDelegate,
    UITextInput {
    
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
    
    private var activeItemIndex: Int?
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
            if config.shouldResignFirstResponderOnReturn {
                DispatchQueue.main.async {
                    self.resignFirstResponder()
                }
            }
            return
        }

        guard !text.isEmpty else { return }

        if activeItemIndex == nil {
            activeItemIndex = 0
        }

        guard let activeItemIndex, activeItemIndex >= 0 else {
            return
        }

        let characters = Array(text)
        var nextItemIndex = activeItemIndex

        while charactersArray.count < config.pinLength {
            charactersArray.append(nil)
        }

        for char in characters {
            if nextItemIndex >= config.pinLength {
                break
            }

            if nextItemIndex < charactersArray.count {
                charactersArray[nextItemIndex] = char
            }

            if nextItemIndex < itemViews.count {
                itemViews[nextItemIndex].setCharacter(char, animated: true)
            }

            nextItemIndex += 1
        }

        self.activeItemIndex = min(nextItemIndex, config.pinLength - 1)

        onPinValueChanged?(self.text)

        if self.text.count == config.pinLength {
            onPinViewEnteredFully?(self.text)
            
            if config.shouldResignFirstResponderOnEnd {
                DispatchQueue.main.async {
                    self.resignFirstResponder()
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
        containerStackView.addInteraction(editMenuInteraction)
        longPressGestureRecognizer.minimumPressDuration = config.pasteGestureMinDuration
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
        charactersArray.removeAll()
        
        for index in 0..<config.pinLength {
            let view = T()
                        
            view.onViewTapped = { [weak self] in
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
    
    // MARK: - UITextInput
    
    // MARK: - Handling text input
    
    // Not used in this view
    public var inputDelegate: (any UITextInputDelegate)?
    
    // MARK: - Replacing and returning text
    
    public func text(in range: UITextRange) -> String? {
        guard let mappedRange = range as? PinTextRange else {
            return nil
        }
                
        if mappedRange.isEmpty {
            return nil
        }
        else {
            return String(text[mappedRange.fullRange(in: text)])
        }
    }
    
    public func replace(_ range: UITextRange, withText text: String) {
        guard let mappedRange = range as? PinTextRange else { return }

        let newCharacters = Array(text)
        let start = mappedRange.startPosition.offset
        let end = mappedRange.endPosition.offset
        
        // Ensure start is within valid bounds
        guard start < config.pinLength else {
            return
        }

        // Calculate the upper bound for replacement
        let upperBound = min(end, config.pinLength - start)
        
        // Replace characters in the specified range
        for i in 0..<upperBound {
            let targetIndex = start + i
            if targetIndex < charactersArray.count, i < newCharacters.count {
                charactersArray[targetIndex] = newCharacters[i]
            }
        }
        
        // Update active item index to the correct position
        activeItemIndex = min(start + newCharacters.count, config.pinLength - 1)
        
        // Trigger event when PIN is fully entered
        if self.text.count == config.pinLength {
            onPinViewEnteredFully?(self.text)
        }
        
        // Refresh UI states
        updateSubviewStates()
        updateAllSubviewValues()
    }
    public func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        // Assume that it should change characters always
        return true
    }
    
    // MARK: - Working with marked and selected text
    
    // Pin code should not be selected with current implementation
    public var selectedTextRange: UITextRange? = nil
    
    // Otp or pin codes not inlude mark text range
    public var markedTextRange: UITextRange? = nil
    public var markedTextStyle: [NSAttributedString.Key : Any]? = nil
    public func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
        // setMarkedText operation takes effect on current focus point (marked or selected)
    }
    public func unmarkText() {
        // unmarkText operation takes effect on current focus point (marked or selected)
    }
    
    // MARK: - Computing text ranges and text positions
    
    public var beginningOfDocument: UITextPosition {
        PinTextPosition(offset: .zero)
    }
    
    public var endOfDocument: UITextPosition {
        PinTextPosition(offset: text.count)
    }
    
    public func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        guard let from = fromPosition as? PinTextPosition, let to = toPosition as? PinTextPosition else {
            return nil
        }
        
        return PinTextRange(from: from, to: to)
    }
    
    public func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        guard let from = position as? PinTextPosition else {
            return nil
        }
        
        // sometimes the system may want to know off-the-one positions, we should just return boundary
        // if we return nil, a guarded fatal error will trigger somewhere else
        let newOffset = max(min(from.offset + offset, text.count), 0)
        return PinTextPosition(offset: newOffset)
    }
    
    public func position(
        from position: UITextPosition,
        in direction: UITextLayoutDirection,
        offset: Int
    ) -> UITextPosition? {
        // View supports only one direction
        self.position(from: position, offset: offset)
    }
    
    // MARK: - Evaluating text positions
    
    public func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
        guard let from = position as? PinTextPosition, let to = other as? PinTextPosition else {
            return .orderedSame
        }
        
        if from.offset < to.offset {
            return .orderedAscending
        }
        
        if from.offset > to.offset {
            return .orderedDescending
        }
        
        return .orderedSame
    }
    
    public func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
        guard let from = from as? PinTextPosition, let to = toPosition as? PinTextPosition else {
            return .zero
        }
        
        return to.offset - from.offset
    }
    
    // MARK: - Deterninging layout and writing direction
    
    public func position(within range: UITextRange, farthestIn direction: UITextLayoutDirection) -> UITextPosition? {
        range.end
    }
    
    public func characterRange(byExtending position: UITextPosition, in direction: UITextLayoutDirection) -> UITextRange? {
        guard let myPosition = position as? PinTextPosition else {
            return nil
        }
        
        return PinTextRange(from: myPosition, to: PinTextPosition(offset: text.count))
    }
    
    public func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> NSWritingDirection {
        .leftToRight
    }
    
    public func setBaseWritingDirection(_ writingDirection: NSWritingDirection, for range: UITextRange) {
        // Do nothing
    }
    
    // MARK: - Geometry and hit-testing
    
    public func firstRect(for range: UITextRange) -> CGRect {
        .zero
    }
    
    // No system caret for this view
    public func caretRect(for position: UITextPosition) -> CGRect {
        .zero
    }
    
    // Pin not selectable
    public func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }
    
    public func closestPosition(to point: CGPoint) -> UITextPosition? {
        nil
    }
    
    public func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
        nil
    }
    
    public func characterRange(at point: CGPoint) -> UITextRange? {
        nil
    }
    
    // MARK: - Tokenizing input text
    
    public var tokenizer: any UITextInputTokenizer {
        get {
            _rawTokenizer
        }
        
        set {
            _rawTokenizer = newValue
        }
    }
    
    private lazy var _rawTokenizer: any UITextInputTokenizer = {
        UITextInputStringTokenizer(textInput: self)
    }()
}
