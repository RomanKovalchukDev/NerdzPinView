//
//  TextStorage.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 18.02.2025.
//

import UIKit

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
