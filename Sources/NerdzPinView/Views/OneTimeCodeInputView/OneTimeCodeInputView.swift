//
//  OneTimeCodeInputView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.02.2025.
//

import UIKit

/// A view that can act as one item cell of a ``OneTimeCodeInputView``.
///
/// Any conforming type is a `UIView` that also renders a one-time code character
/// (``OneTimeCodeItemViewType``) and is both layout and appearance configurable.
public typealias OneTimeCodeItemView = UIView & OneTimeCodeItemViewType & ItemViewLayoutConfigurable & ItemViewAppearanceConfigurable

/// A generic one-time code input backed by a full `UITextInput` implementation.
///
/// Unlike ``PinCodeInputView``, this view integrates with the system text input
/// machinery, so it supports the caret, text selection ranges, and one-time code
/// autofill. It manages one item view of type `T` per character and can group
/// the items into two halves. It reports edits through ``onPinValueChanged`` and
/// completion through ``onPinViewEnteredFully``. Use
/// ``DesignableOneTimeCodeInputView`` for a ready to use configuration.
@MainActor
public class OneTimeCodeInputView<T: OneTimeCodeItemView>: UIView, UITextInput, @preconcurrency UIEditMenuInteractionDelegate {

    // MARK: - Internal types

    /// The overall state of the one-time code input.
    public enum ViewState {
        /// The input cannot receive text.
        case disabled

        /// The input is idle and accepts text.
        case normal

        /// The input is presenting an error and highlights every item accordingly.
        case error
    }

    /// Behavior and layout options for a ``OneTimeCodeInputView``.
    public struct Config {
        /// The number of characters the input accepts.
        public var pinLength: Int

        /// The placeholder character shown in empty items, or `nil` for none.
        public var placeholderCharacter: Character?

        /// The title of the paste action shown in the edit menu.
        public var pasteActionTitle: String

        /// A Boolean value indicating whether the items are split into two visually separated groups.
        public var shouldGroupNumbers: Bool

        /// The spacing between adjacent items.
        public var itemSpacing: CGFloat

        /// The spacing between the two groups when grouping is enabled.
        public var groupSpacing: CGFloat

        /// Creates a one-time code input configuration.
        ///
        /// - Parameters:
        ///   - pinLength: The number of characters the input accepts.
        ///   - placeholderCharacter: The placeholder character shown in empty items, or `nil` for none.
        ///   - pasteActionTitle: The title of the paste action shown in the edit menu.
        ///   - shouldGroupNumbers: Whether the items are split into two visually separated groups.
        ///   - itemSpacing: The spacing between adjacent items.
        ///   - groupSpacing: The spacing between the two groups when grouping is enabled.
        public init(
            pinLength: Int = 6,
            placeholderCharacter: Character? = nil,
            pasteActionTitle: String = "Paste",
            shouldGroupNumbers: Bool = true,
            itemSpacing: CGFloat = 8,
            groupSpacing: CGFloat = 16
        ) {
            self.pinLength = pinLength
            self.placeholderCharacter = placeholderCharacter
            self.pasteActionTitle = pasteActionTitle
            self.shouldGroupNumbers = shouldGroupNumbers
            self.itemSpacing = itemSpacing
            self.groupSpacing = groupSpacing
        }
    }
    
    class TextPosition: UITextPosition {
        let index: Int

        init(_ index: Int) {
            self.index = index
        }

        public override var description: String {
            let props: [String] = [
               "index = \(String(describing: index))"
            ]
            return "<\(props.joined(separator: "; "))>"
        }

        public override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? TextPosition else {
                return false
            }

            return self.index == other.index
        }

        func compare(_ otherPosition: TextPosition) -> ComparisonResult {
            if index < otherPosition.index {
                return .orderedAscending
            }

            if index > otherPosition.index {
                return .orderedDescending
            }

            return .orderedSame
        }
    }

    final class TextRange: UITextRange {
        
        let _start: TextPosition
        let _end: TextPosition

        public override var isEmpty: Bool {
            return _start.index == _end.index
        }

        public override var start: UITextPosition {
            return _start
        }

        public override var end: UITextPosition {
            return _end
        }
        
        public override var description: String {
            let props: [String] = [
                "start = \(_start.description)",
                "end = \(_end.description)",
            ]
            return "<\(props.joined(separator: "; "))>"
        }

        public convenience init?(start: UITextPosition, end: UITextPosition) {
            guard let start = start as? TextPosition, let end = end as? TextPosition else {
                return nil
            }

            self.init(start: start, end: end)
        }

        public init(start: TextPosition, end: TextPosition) {
            self._start = start
            self._end = end
        }

        public override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? TextRange else {
                return false
            }

            return self._start == other._start && self._end == other._end
        }

        public func contains(_ index: Int) -> Bool {
            let lowerBound = min(_start.index, _end.index)
            let upperBound = max(_start.index, _end.index)
            return index >= lowerBound && index <= upperBound
        }

        public func stringRange(for string: String) -> Range<String.Index> {
            let lowerBound = min(_start.index, _end.index)
            let upperBound = max(_start.index, _end.index)

            let beginIndex = string.index(string.startIndex, offsetBy: min(lowerBound, string.count))
            let endIndex = string.index(string.startIndex, offsetBy: min(upperBound, string.count))

            return beginIndex..<endIndex
        }
    }
    
    @MainActor
    final class TextStorage {
        
        let capacity: Int
        
        var value: String = ""

        var start: TextPosition {
             TextPosition(0)
        }

        var end: TextPosition {
            TextPosition(value.count)
        }

        /// Returns a range for placing the caret at the end of the content.
        ///
        /// A zero-length range is `UITextInput`'s way of representing the caret position. This property will
        /// always return a zero-length range at the end of the content.
        var endCaretRange: TextRange {
            TextRange(start: end, end: end)
        }

        /// A range that covers from the beginning to the end of the content.
        var extent: TextRange {
            TextRange(start: start, end: end)
        }

        var isFull: Bool {
            value.count >= capacity
        }

        var allowedCharacters: CharacterSet = .alphanumerics

        init(capacity: Int) {
            assert(capacity >= 0, "Cannot have a negative capacity")
            
            self.capacity = max(capacity, 0)
        }

        func insert(_ text: String, at range: TextRange) -> TextRange {
            let sanitizedText = text.filter({
                $0.unicodeScalars.allSatisfy(allowedCharacters.contains(_:))
            })

            value.replaceSubrange(range.stringRange(for: value), with: sanitizedText)

            if value.count > capacity {
                // Truncate to capacity
                value = String(value.prefix(capacity))
            }

            let nextInsertionIndex = min((range._start.index + sanitizedText.count), capacity)
            let newInsertionPoint = TextPosition(nextInsertionIndex)
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
            guard extent.contains(start.index), extent.contains(end.index) else {
                return nil
            }

            return TextRange(start: start, end: end)
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

    /// The one-time code value without formatting.
    public var value: String {
        get {
            textStorage.value
        }
        set {
            textStorage.value = newValue
            
            update()
        }
    }
    
    /// The behavior and layout configuration. Assigning a new value rebuilds the item views.
    public var config: Config = Config() {
        didSet {
            configureView()
        }
    }

    /// The overall state of the input, propagated to every item view.
    public var viewState: ViewState = .normal {
        didSet {
            update()
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
        !value.isEmpty
    }

    /// The autocorrection behavior for the keyboard.
    public var autocorrectionType: UITextAutocorrectionType = .no

    /// The keyboard type presented for input.
    public var keyboardType: UIKeyboardType = .numberPad

    /// The title of the keyboard return key.
    public var returnKeyType: UIReturnKeyType = .done

    /// The semantic meaning of the text, used for autofill. Defaults to one-time code.
    public var textContentType: UITextContentType! = .oneTimeCode
    
    // MARK: - Properties(private)
        
    private var itemViews: [T] = []
    private var textStorage: TextStorage = TextStorage(capacity: .zero)
    private lazy var editMenuInteraction: UIEditMenuInteraction = UIEditMenuInteraction(delegate: self)
    
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

    /// Inserts the pasteboard string at the current caret position.
    ///
    /// - Parameter sender: The object requesting the paste.
    open override func paste(_ sender: Any?) {
        guard let string = UIPasteboard.general.string else {
            return
        }

        insertText(string)
    }

    // MARK: - UIKeyInput

    /// Inserts text at the current selection, clamping to the configured length.
    ///
    /// - Parameter text: The text to insert. Characters beyond the remaining capacity are dropped.
    open func insertText(_ text: String) {
        guard let range = selectedTextRange as? TextRange else {
            return
        }

        inputDelegate?.textWillChange(self)
        selectedTextRange = textStorage.insert(text, at: range)
        inputDelegate?.textDidChange(self)
        
        notifyViewAfterUpdates()
        update()
    }

    /// Deletes the character before the caret, or the current selection.
    open func deleteBackward() {
        guard let range = selectedTextRange as? TextRange else {
            return
        }

        inputDelegate?.textWillChange(self)
        selectedTextRange = textStorage.delete(range: range)
        inputDelegate?.textDidChange(self)
        
        notifyViewAfterUpdates()
        update()
    }
    
    private func notifyViewAfterUpdates() {
        onPinValueChanged?(textStorage.value)
                
        if textStorage.isFull {
            onPinViewEnteredFully?(value)
            resignFirstResponder()
        }
    }
    
    // MARK: - UIResponder
    
    /// Makes the input active, placing the caret at the end of the current value.
    ///
    /// - Returns: `true` if the input became first responder.
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()

        if result {
            selectedTextRange = textStorage.endCaretRange
            
            if viewState == .error {
                viewState = .normal
            }
            
            onBecomeFirstResponder?()
        }
        
        return result
    }
    
    /// Deactivates the input and refreshes the item views.
    ///
    /// - Returns: `true` if the input resigned first responder.
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()

        if result {
            update()

            onResignFirstResponder?()
        }

        return result
    }

    /// Handles taps, showing the edit menu when already active or becoming first responder otherwise.
    ///
    /// - Parameters:
    ///   - touches: The touches that ended.
    ///   - event: The event the touches belong to.
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let point = touches.first?.location(in: self), bounds.contains(point) else {
            return
        }

        if isFirstResponder {
            showMenu()
        }
        else {
            becomeFirstResponder()
        }
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
    
    // MARK: - Methods(private)
    
    private func showMenu() {
        let location = CGPoint(x: bounds.midX, y: bounds.midY)
        let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
        editMenuInteraction.presentEditMenu(with: configuration)
    }
    
    private func configureView() {
        self.addInteraction(editMenuInteraction)
        self.textStorage = TextStorage(capacity: config.pinLength)
        
        self.itemViews = (0..<config.pinLength).map { _ in
            let view = T()
            
            view.placeholderCharacter = config.placeholderCharacter
            view.layoutConfig = layoutConfig
            view.appearanceConfig = appearanceConfig
            
            return view
        }
        
        subviews.forEach({ $0.removeFromSuperview() })
        
        let stackView = UIStackView(arrangedSubviews: arrangedItemViews())
        stackView.spacing = config.shouldGroupNumbers ? config.groupSpacing : config.itemSpacing
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.semanticContentAttribute = .forceLeftToRight
        
        addAndFillSubview(stackView, directionalLayoutMargins: .zero)
        
        update()
    }
    
    private func arrangedItemViews() -> [UIView] {
        guard config.shouldGroupNumbers else {
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
        let selectedRange = selectedTextRange as? TextRange
        
        for (index, itemView) in itemViews.enumerated() {
            
            let newValue = index < digits.count ? digits[index] : nil
            itemView.valueCharacter = newValue
            
            switch viewState {
            case .disabled:
                itemView.viewState = .disabled
                
            case .normal:
                itemView.viewState = isFirstResponder && (selectedRange?.contains(index) ?? false) ? .active : .normal
                
            case .error:
                itemView.viewState = .error
            }
        }
    }
    
    private func updateAccessibilityProperties() {
        accessibilityValue = value
    }
    
    private func clampIndex(_ index: Int) -> Int {
        max(min(index, config.pinLength - 1), 0)
    }
    
    // MARK: - UITextInput
    
    // MARK: - Handling text input

    /// The delegate notified of text and selection changes. Not used by this view.
    public var inputDelegate: (any UITextInputDelegate)?

    // MARK: - Replacing and returning text

    /// Returns the substring covered by a text range.
    ///
    /// - Parameter range: The range to read.
    /// - Returns: The text in the range, or `nil` when the range is empty or invalid.
    public func text(in range: UITextRange) -> String? {
        guard let range = range as? TextRange else {
            return nil
        }

        return textStorage.text(in: range)
    }

    /// Replaces the text in a range. This view ignores direct replacements.
    ///
    /// - Parameters:
    ///   - range: The range to replace.
    ///   - text: The replacement text.
    public func replace(_ range: UITextRange, withText text: String) {
        // Do nothing
    }

    /// Reports whether a proposed text change is allowed, always `true` for this view.
    ///
    /// - Parameters:
    ///   - range: The range that would change.
    ///   - text: The replacement text.
    /// - Returns: Always `true`.
    public func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        // Assume that it should change characters always
        return true
    }

    // MARK: - Working with marked and selected text

    /// The current selection, expressed as a range. A zero-length range represents the caret.
    public var selectedTextRange: UITextRange? = nil {
        willSet {
            inputDelegate?.selectionWillChange(self)
        }
        didSet {
            inputDelegate?.selectionDidChange(self)
            update()
        }
    }

    /// The range of marked text. Marked text is unsupported, so this is always `nil`.
    public var markedTextRange: UITextRange? {
        return nil
    }

    /// The style for marked text. Marked text is unsupported, so this is always `nil`.
    public var markedTextStyle: [NSAttributedString.Key : Any]? {
        get {
            return nil
        }
        set {
            // We don't support marked text
        }
    }

    /// Sets marked text. Marked text is unsupported, so this does nothing.
    ///
    /// - Parameters:
    ///   - markedText: The text to mark.
    ///   - selectedRange: The selection within the marked text.
    public func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
        // We don't support marked text
    }

    /// Removes any marked text. Marked text is unsupported, so this does nothing.
    public func unmarkText() {
        // We don't support marked text
    }

    // MARK: - Computing text ranges and text positions

    /// The position at the start of the value.
    public var beginningOfDocument: UITextPosition {
        textStorage.start
    }

    /// The position at the end of the value.
    public var endOfDocument: UITextPosition {
        textStorage.end
    }

    /// Creates a range between two positions.
    ///
    /// - Parameters:
    ///   - fromPosition: The start position.
    ///   - toPosition: The end position.
    /// - Returns: The range, or `nil` when either position is invalid.
    public func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        guard let fromPosition = fromPosition as? TextPosition, let toPosition = toPosition as? TextPosition else {
            return nil
        }

        return textStorage.makeRange(from: fromPosition, to: toPosition)
    }

    /// Returns the position a given offset away from another position.
    ///
    /// - Parameters:
    ///   - position: The starting position.
    ///   - offset: The signed number of characters to move.
    /// - Returns: The resulting position, or `nil` when it falls out of bounds.
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

    /// Returns the position a given offset away from another position in a layout direction.
    ///
    /// - Parameters:
    ///   - position: The starting position.
    ///   - direction: The layout direction to move in.
    ///   - offset: The number of characters to move.
    /// - Returns: The resulting position, or `nil` when it falls out of bounds.
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

    /// Compares two positions.
    ///
    /// - Parameters:
    ///   - position: The first position.
    ///   - other: The second position.
    /// - Returns: The ordering of the two positions.
    public func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
        guard let position = position as? TextPosition, let other = other as? TextPosition else {
            return .orderedSame
        }

        return position.compare(other)
    }

    /// Returns the character distance between two positions.
    ///
    /// - Parameters:
    ///   - from: The starting position.
    ///   - toPosition: The ending position.
    /// - Returns: The signed number of characters between the positions.
    public func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
        guard let from = from as? TextPosition, let toPosition = toPosition as? TextPosition else {
            return 0
        }

        return toPosition.index - from.index
    }

    // MARK: - Deterninging layout and writing direction

    /// Returns the position farthest in a direction within a range.
    ///
    /// - Parameters:
    ///   - range: The range to search within.
    ///   - direction: The layout direction.
    /// - Returns: The farthest position, or `nil` when the range is invalid.
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
    
    /// Returns the range obtained by extending a position toward a direction.
    ///
    /// - Parameters:
    ///   - position: The anchor position.
    ///   - direction: The direction to extend toward.
    /// - Returns: The extended range, or `nil` for vertical directions.
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

    /// Returns the base writing direction, always left to right for code input.
    ///
    /// - Parameters:
    ///   - position: The position to query.
    ///   - direction: The storage direction to consider.
    /// - Returns: Always `.leftToRight`.
    public func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> NSWritingDirection {
        // OTP input should be left-to-right always.
        .leftToRight
    }

    /// Sets the base writing direction for a range. The direction is fixed, so this does nothing.
    ///
    /// - Parameters:
    ///   - writingDirection: The requested writing direction.
    ///   - range: The range to apply it to.
    public func setBaseWritingDirection(_ writingDirection: NSWritingDirection, for range: UITextRange) {
        // Do nothing
    }

    // MARK: - Geometry and hit-testing

    /// Returns the rectangle enclosing the item views covered by a range.
    ///
    /// - Parameter range: The range to measure.
    /// - Returns: The bounding rectangle, or `.zero` when the range is empty or invalid.
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
    
    /// Returns the caret rectangle for a position, in the input's coordinate space.
    ///
    /// - Parameter position: The position to locate the caret at.
    /// - Returns: The caret rectangle, or `.zero` when the position is invalid.
    public func caretRect(for position: UITextPosition) -> CGRect {
        guard let position = position as? TextPosition else {
            return .zero
        }

        let digitView = itemViews[clampIndex(position.index)]
        return digitView.convert(digitView.caretRect, to: self)
    }

    /// Returns the selection rectangles for a range. Text selection is unsupported, so this is empty.
    ///
    /// - Parameter range: The range to measure.
    /// - Returns: Always an empty array.
    public func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        // No text-selection
        return []
    }

    /// Returns the position closest to a point anywhere in the input.
    ///
    /// - Parameter point: The point, in the input's coordinate space.
    /// - Returns: The closest position, or `nil` when no item is hit.
    public func closestPosition(to point: CGPoint) -> UITextPosition? {
        return closestPosition(to: point, within: textStorage.extent)
    }

    /// Returns the position closest to a point within a range.
    ///
    /// - Parameters:
    ///   - point: The point, in the input's coordinate space.
    ///   - range: The range to restrict the result to.
    /// - Returns: The closest position inside the range, or `nil` when no item is hit.
    public func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
        guard let range = range as? TextRange, let digitView = hitTest(point, with: nil) as? T, let index = itemViews.firstIndex(of: digitView) else {
            return nil
        }

        return range.contains(index) ? TextPosition(index) : nil
    }

    /// Returns the single character range at a point.
    ///
    /// - Parameter point: The point, in the input's coordinate space.
    /// - Returns: A one character range at the point, or `nil` when no item is hit.
    public func characterRange(at point: CGPoint) -> UITextRange? {
        guard let startPosition = closestPosition(to: point) as? TextPosition, let endPosition = position(from: startPosition, offset: 1) else {
            return nil
        }

        return self.textRange(from: startPosition, to: endPosition)
    }

    // MARK: - Tokenizing input text

    /// The tokenizer used to segment the input text into words and other units.
    public lazy var tokenizer: any UITextInputTokenizer = UITextInputStringTokenizer(textInput: self)
}
