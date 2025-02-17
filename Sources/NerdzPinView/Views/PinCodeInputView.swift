//
//  PinCodeInputView.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

import UIKit

@MainActor
final class TextStorage {
    var value: String = ""

    let capacity: Int

    var start: TextPosition {
        return TextPosition(0)
    }

    var end: TextPosition {
        return TextPosition(value.count)
    }

    /// Returns a range for placing the caret at the end of the content.
    ///
    /// A zero-length range is `UITextInput`'s way of representing the caret position. This property will
    /// always return a zero-length range at the end of the content.
    var endCaretRange: TextRange {
        return TextRange(start: end, end: end)
    }

    /// A range that covers from the beginning to the end of the content.
    var extent: TextRange {
        return TextRange(start: start, end: end)
    }

    var isFull: Bool {
        return value.count >= capacity
    }

//    private let allowedCharacters: CharacterSet = .init(charactersIn: "0123456789")

    init(capacity: Int) {
        assert(capacity >= 0, "Cannot have a negative capacity")
        
        self.capacity = max(capacity, 0)
    }

    func insert(_ text: String, at range: TextRange) -> TextRange {
        let sanitizedText = text //.filter({
//            $0.unicodeScalars.allSatisfy(allowedCharacters.contains(_:))
//        })

        value.replaceSubrange(range.stringRange(for: value), with: sanitizedText)

        if value.count > capacity {
            // Truncate to capacity
            value = String(value.prefix(capacity))
        }

        let newInsertionPoint = TextPosition(range._start.index + sanitizedText.count)
        return TextRange(start: newInsertionPoint, end: newInsertionPoint)
    }

    func delete(range: TextRange) -> TextRange {
        value.removeSubrange(range.stringRange(for: value))
        return TextRange(start: range._start, end: range._start)
    }

    func text(in range: TextRange) -> String? {
        guard !range.isEmpty else {
            return nil
        }

        let stringRange = range.stringRange(for: value)
        return String(value[stringRange])
    }

    /// Utility method for creating a text range.
    ///
    /// Returns `nil` if any of the given positions is out of bounds.
    ///
    /// - Parameters:
    ///   - start: Start position of the range.
    ///   - end: End position of the range.
    /// - Returns: Text position.
    func makeRange(from start: TextPosition, to end: TextPosition) -> TextRange? {
        guard
            extent.contains(start.index),
            extent.contains(end.index)
        else {
            return nil
        }

        return TextRange(start: start, end: end)
    }
}

public typealias DigitViewType = UIView & PinCodeItemViewType & PinCodeItemLayoutConfigurable & PinCodeItemAppearanceConfigurable

@MainActor
public class PinCodeInputView<T: DigitViewType>: UIView, UIKeyInput, @preconcurrency UIEditMenuInteractionDelegate, UITextInput {
    
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
    
    /// The one-time code value without formatting.
    public var value: String {
        get {
            return textStorage.value
        }
        set {
            textStorage.value = newValue
            update()
        }
    }
    
    public var config: PinViewConfig = PinViewConfig() {
        didSet {
            configureView()
        }
    }
    
    public var viewState: ViewState = .normal {
        didSet {
            update()
//            updateSubviewStates()
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
        !value.isEmpty
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
        
    private lazy var itemViews: [T] = (0...config.pinLength).map { _ in
        let view = T()
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalTo: view.widthAnchor)
        ])
        return view
    }
    
    private var textStorage: TextStorage = TextStorage(capacity: .zero)
    
    private lazy var editMenuInteraction: UIEditMenuInteraction = UIEditMenuInteraction(delegate: self)
    
//    private lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
//        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
//        gesture.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
//        return gesture
//    }()
//    
//    // MARK: - IBActions
//    
//    @IBAction private func didLongPress(_ recognizer: UIGestureRecognizer) {
//        let location = recognizer.location(in: containerStackView)
//        let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
//        editMenuInteraction.presentEditMenu(with: configuration)
//    }
    
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
        guard let string = UIPasteboard.general.string else {
            return
        }
        
        insertText(string)
        update()
    }
    
    // MARK: - UIKeyInput
    
    open func insertText(_ text: String) {
        guard let range = selectedTextRange as? TextRange else {
            return
        }

        inputDelegate?.textWillChange(self)
        selectedTextRange = textStorage.insert(text, at: range)
        inputDelegate?.textDidChange(self)
        
        onPinValueChanged?(textStorage.value)
        
        if textStorage.isFull {
            onPinViewEnteredFully?(value)
        }

//        sendActions(for: [.editingChanged, .valueChanged])
        #if !canImport(CompositorServices)
//        hideMenu()
        #endif
        update()
    }

    open func deleteBackward() {
        guard let range = selectedTextRange as? TextRange else {
            return
        }

        inputDelegate?.textWillChange(self)
        selectedTextRange = textStorage.delete(range: range)
        inputDelegate?.textDidChange(self)
        
        onPinValueChanged?(textStorage.value)
        
        if textStorage.isFull {
            onPinViewEnteredFully?(value)
        }

//        sendActions(for: [.editingChanged, .valueChanged])
        #if !canImport(CompositorServices)
//        hideMenu()
        #endif
        update()
    }
    
    // MARK: - UIResponder
    
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()

        if result {
            selectedTextRange = textStorage.endCaretRange
        }
        
        if viewState == .error {
            viewState = .normal
        }
        
        onBecomeFirstResponder?()

        return result
    }
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        
        if result {
            update()
        }
        
        onResignFirstResponder?()
        
        return result
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let point = touches.first?.location(in: self),
              bounds.contains(point) else {
            return
        }

        if isFirstResponder {
            // show menu
        }
        else {
            becomeFirstResponder()
        }
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
    
    // MARK: - Methods(private)
    
    private func configureView() {
        self.textStorage = TextStorage(capacity: config.pinLength)
        let stackView = UIStackView(arrangedSubviews: arrangedItemViews())
        stackView.spacing = true ? config.groupSpacing : config.itemSpacing
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.semanticContentAttribute = .forceLeftToRight
        addAndPinSubview(stackView, directionalLayoutMargins: .zero)
    }
    
    private func arrangedItemViews() -> [UIView] {
        guard true else {
            // No grouping, simply return all the digit views.
            return itemViews
        }

        // Split the digit views into two groups.
        let groupSize = config.pinLength / 2

        let groups = stride(from: 0, to: itemViews.count, by: groupSize).map {
            Array(itemViews[$0..<min($0 + groupSize, itemViews.count)])
        }

        return groups.map {
            let groupView = UIStackView(arrangedSubviews: $0)
            groupView.spacing = config.itemSpacing
            groupView.distribution = .fillEqually
            groupView.semanticContentAttribute = .forceLeftToRight
            return groupView
        }
    }
    
    private func update() {
        updateItemViews()
        updateAccessibilityProperties()
    }
    
    private func updateItemViews() {
        let digits: [Character] = .init(value)
        
        for (index, itemView) in itemViews.enumerated() {
            itemView.shouldSecureText = isSecureTextEntry
            itemView.layoutConfig = layoutConfig
            itemView.appearanceConfig = appearanceConfig
            itemView.placeholderCharacter = config.placeholderCharacter
            itemView.secureTextCharacter = config.secureTextCharacter
            itemView.secureTextDelay = config.secureTextDelay
            itemView.setCharacter(index < digits.count ? digits[index] : nil, animated: false)
            
            switch viewState {
            case .disabled:
                itemView.viewState = .disabled
                
            case .normal:
                itemView.viewState = .normal // index == activeItemIndex ? .active : .normal
                
            case .error:
                itemView.viewState = .error
            }
        }
    }
    
    private func updateAccessibilityProperties() {
    }
        
//    private func configureSubviews() {
//        containerStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
//        charactersArray.removeAll()
//        
//        for index in 0..<config.pinLength {
//            let view = T()
//                        
//            view.onViewTapped = { [weak self] in
//                self?.activeItemIndex = index
//                self?.becomeFirstResponder()
//            }
//            
//            view.translatesAutoresizingMaskIntoConstraints = false
//
//            // Add width and height constraints to maintain a 1:1 aspect ratio
//            NSLayoutConstraint.activate([
//                view.heightAnchor.constraint(equalTo: view.widthAnchor)
//            ])
//            
//            view.layoutConfig = layoutConfig
//            view.appearanceConfig = appearanceConfig
//            view.placeholderCharacter = config.placeholderCharacter
//            view.secureTextCharacter = config.secureTextCharacter
//            view.secureTextDelay = config.secureTextDelay
//                                                
//            charactersArray.append(nil)
//            containerStackView.addArrangedSubview(view)
//        }
//    }
    
//    private func updateAllSubviewValues() {
//        for (index, itemView) in itemViews.enumerated() {
//            itemView.setCharacter(charactersArray[index], animated: false)
//        }
//    }
    
//    private func updateSubviewStates() {
//        for (index, itemView) in itemViews.enumerated() {
//            itemView.shouldSecureText = isSecureTextEntry
//            
//            switch viewState {
//            case .disabled:
//                itemView.viewState = .disabled
//                
//            case .normal:
//                itemView.viewState = index == activeItemIndex ? .active : .normal
//                
//            case .error:
//                itemView.viewState = .error
//            }
//        }
//    }
    
    private func clampIndex(_ index: Int) -> Int {
        return max(min(index, config.pinLength - 1), 0)
    }
    
    // MARK: - UITextInput
    
    // MARK: - Handling text input
    
    // Not used in this view
    public var inputDelegate: (any UITextInputDelegate)?
    
    // MARK: - Replacing and returning text
    
    public func text(in range: UITextRange) -> String? {
        guard let range = range as? TextRange else {
            return nil
        }

        return textStorage.text(in: range)
    }
    
    public func replace(_ range: UITextRange, withText text: String) {
        // Do nothing
    }
    
    public func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        // Assume that it should change characters always
        return true
    }
    
    // MARK: - Working with marked and selected text
    
    public var selectedTextRange: UITextRange? = nil {
        willSet {
            inputDelegate?.selectionWillChange(self)
        }
        didSet {
            inputDelegate?.selectionDidChange(self)
            update()
        }
    }
    
    // Otp or pin codes not inlude mark text range
    
    public var markedTextRange: UITextRange? {
        return nil
    }
    
    public var markedTextStyle: [NSAttributedString.Key : Any]? {
        get {
            return nil
        }
        set {
            // We don't support marked text
        }
    }
    
    public func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
        // We don't support marked text
    }
    
    public func unmarkText() {
        // We don't support marked text
    }
    
    // MARK: - Computing text ranges and text positions
    
    public var beginningOfDocument: UITextPosition {
        return textStorage.start
    }
    
    public var endOfDocument: UITextPosition {
        return textStorage.end
    }
    
    public func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        guard let fromPosition = fromPosition as? TextPosition, let toPosition = toPosition as? TextPosition else {
            return nil
        }

        return textStorage.makeRange(from: fromPosition, to: toPosition)
    }
    
    public func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        guard let position = position as? TextPosition else {
            return nil
        }

        let newIndex = position.index + offset

        guard textStorage.extent.contains(newIndex) else {
            // Out of bounds
            return nil
        }

        return TextPosition(newIndex)
    }
    
    public func position(
        from position: UITextPosition,
        in direction: UITextLayoutDirection,
        offset: Int
    ) -> UITextPosition? {
        switch direction {
        case .right:
            return self.position(from: position, offset: offset)
            
        case .left:
            return self.position(from: position, offset: -offset)
            
        case .up:
            return offset > 0 ? beginningOfDocument : endOfDocument
            
        case .down:
            return offset > 0 ? endOfDocument : beginningOfDocument
            
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Evaluating text positions
    
    public func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
        guard let position = position as? TextPosition, let other = other as? TextPosition else {
            return .orderedSame
        }

        return position.compare(other)
    }
    
    public func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
        guard let from = from as? TextPosition, let toPosition = toPosition as? TextPosition else {
            return 0
        }

        return toPosition.index - from.index
    }
    
    // MARK: - Deterninging layout and writing direction
    
    public func position(within range: UITextRange, farthestIn direction: UITextLayoutDirection) -> UITextPosition? {
        guard let range = range as? TextRange else {
            return nil
        }

        switch direction {
        case .left, .up:
            return range.start
            
        case .right, .down:
            return range.end
            
        @unknown default:
            return nil
        }
    }
    
    public func characterRange(byExtending position: UITextPosition, in direction: UITextLayoutDirection) -> UITextRange? {
        switch direction {
        case .right:
            return self.textRange(from: position, to: endOfDocument)
            
        case .left:
            return self.textRange(from: beginningOfDocument, to: position)
            
        case .up, .down:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    public func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> NSWritingDirection {
        // OTP input should be left-to-right always.
        .leftToRight
    }
    
    public func setBaseWritingDirection(_ writingDirection: NSWritingDirection, for range: UITextRange) {
        // Do nothing
    }
    
    // MARK: - Geometry and hit-testing
    
    public func firstRect(for range: UITextRange) -> CGRect {
        guard let range = range as? TextRange, !range.isEmpty else {
            return .zero
        }

        // This method should return a rectangle that contains the digit views that
        // fall inside the given TextRange. For example, a [0,2] TextRange should
        // return a rectangle that contains digit views 0 and 1:
        //
        // 0   1   2    3    4   5   6  <- TextPosition
        //  [*] [*] [*]   [*] [*] [*]   <- UI
        //   0   1   2     3   4   5    <- DigitView index
        // ^       ^
        // |_______|                    <- [0,2] TextRange

        let firstDigitView = itemViews[clampIndex(range._start.index)]
        let secondDigitView = itemViews[clampIndex(range._end.index - 1)]

        let firstRect = firstDigitView.convert(firstDigitView.bounds, to: self)
        let secondRect = secondDigitView.convert(secondDigitView.bounds, to: self)

        return firstRect.union(secondRect)
    }
    
    public func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
//        guard let position = position as? TextPosition else {
//            return .zero
//        }
//
//        let digitView = itemViews[clampIndex(position.index)]
//        return digitView.convert(digitView.caretRect, to: self)
    }
    
    public func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        // No text-selection
        return []
    }
    
    public func closestPosition(to point: CGPoint) -> UITextPosition? {
        return closestPosition(to: point, within: textStorage.extent)
    }
    
    public func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
        guard let range = range as? TextRange, let digitView = hitTest(point, with: nil) as? T, let index = itemViews.firstIndex(of: digitView) else {
            return nil
        }

        return range.contains(index) ? TextPosition(index) : nil
    }
    
    public func characterRange(at point: CGPoint) -> UITextRange? {
        guard let startPosition = closestPosition(to: point) as? TextPosition, let endPosition = position(from: startPosition, offset: 1) else {
            return nil
        }

        return self.textRange(from: startPosition, to: endPosition)
    }
    
    // MARK: - Tokenizing input text
    
    public lazy var tokenizer: any UITextInputTokenizer = UITextInputStringTokenizer(textInput: self)
}
