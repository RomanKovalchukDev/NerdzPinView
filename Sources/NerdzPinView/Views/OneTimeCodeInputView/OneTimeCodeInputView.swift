//
//  OneTimeCodeInputView.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.02.2025.
//

import UIKit

public typealias OneTimeCodeItemView = UIView & OneTimeCodeItemViewType & ItemViewLayoutConfigurable & ItemViewAppearanceConfigurable

@MainActor
public class OneTimeCodeInputView<T: OneTimeCodeItemView>: UIView, UITextInput, @preconcurrency UIEditMenuInteractionDelegate {
    
    // MARK: - Internal types
    
    public enum ViewState {
        case disabled
        case normal
        case error
    }
    
    public struct Config {
        public var pinLength: Int
        public var placeholderCharacter: Character?
        public var pasteActionTitle: String
        public var shouldGroupNumbers: Bool
        public var itemSpacing: CGFloat
        public var groupSpacing: CGFloat
        
        init(
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
    
    public var onPinValueChanged: PinCodeTextAction?
    public var onPinViewEnteredFully: PinCodeTextAction?
    public var onBecomeFirstResponder: PinCodeEmptyAction?
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
    
    public var config: Config = Config() {
        didSet {
            configureView()
        }
    }
    
    public var viewState: ViewState = .normal {
        didSet {
            update()
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
    
    public var autocorrectionType: UITextAutocorrectionType = .no
    public var keyboardType: UIKeyboardType = .numberPad
    public var returnKeyType: UIReturnKeyType = .done
    public var textContentType: UITextContentType! = .oneTimeCode
    
    // MARK: - Properties(private)
        
    private var itemViews: [T] = []
    private var textStorage: TextStorage = TextStorage(capacity: .zero)
    private lazy var editMenuInteraction: UIEditMenuInteraction = UIEditMenuInteraction(delegate: self)
    
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
    }
    
    // MARK: - UIKeyInput
    
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
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        
        if result {
            update()
            
            onResignFirstResponder?()
        }
        
        return result
    }
    
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
        textStorage.start
    }
    
    public var endOfDocument: UITextPosition {
        textStorage.end
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
        guard let position = position as? TextPosition else {
            return .zero
        }

        let digitView = itemViews[clampIndex(position.index)]
        return digitView.convert(digitView.caretRect, to: self)
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
