//
//  PinTextRange.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 14.02.2025.
//

import UIKit

/// A range of characters inside a pin code string, bounded by two ``PinTextPosition`` values.
///
/// This is the module's concrete `UITextRange` used by the `UITextInput`
/// conformances to describe selections and insertion ranges.
open class PinTextRange: UITextRange {

    /// The position at the start of the range.
    public let startPosition: PinTextPosition

    /// The position at the end of the range.
    public let endPosition: PinTextPosition

    /// The number of characters spanned by the range.
    public var length: Int {
        endPosition.offset - startPosition.offset
    }

    /// A textual representation of the range, used for debugging.
    public override var description: String {
        "[\(startPosition.offset) ..< \(endPosition.offset)]"
    }

    /// The start of the range, as a `UITextPosition`.
    public override var start: UITextPosition {
        startPosition
    }

    /// The end of the range, as a `UITextPosition`.
    public override var end: UITextPosition {
        endPosition
    }

    /// A Boolean value indicating whether the range spans no characters.
    public override var isEmpty: Bool {
        startPosition.offset >= endPosition.offset
    }

    /// Creates a range between two positions, or `nil` when the bounds are not strictly increasing.
    ///
    /// - Parameters:
    ///   - from: The start position.
    ///   - to: The end position, which must be strictly greater than `from`.
    public init?(from: PinTextPosition, to: PinTextPosition) {
        guard from.offset < to.offset else {
            return nil
        }

        self.startPosition = from
        self.endPosition = to
    }

    /// Creates a range that extends from a position by a signed character count, clamped to the base string.
    ///
    /// A positive `maxOffset` extends forward from `from`, while a negative
    /// value extends backward. The resulting bounds are clamped so they stay
    /// within `baseString`.
    ///
    /// - Parameters:
    ///   - from: The anchor position the range extends from.
    ///   - maxOffset: The signed number of characters to extend by. May be negative.
    ///   - baseString: The string the offsets are clamped against.
    public init(from: PinTextPosition, maxOffset: Int, in baseString: String) {
        if maxOffset >= 0 {
            self.startPosition = from
            let end = min(baseString.count, from.offset + maxOffset)
            self.endPosition = PinTextPosition(offset: end)
        }
        else {
            self.endPosition = from
            let begin = max(0, from.offset + maxOffset)
            self.startPosition = PinTextPosition(offset: begin)
        }
    }
    
    /// Converts the range into a `String.Index` range within the given string.
    ///
    /// - Parameter baseString: The string the offsets are resolved against.
    /// - Returns: The equivalent `String.Index` range inside `baseString`.
    public func fullRange(in baseString: String) -> Range<String.Index> {
        let beginIndex = baseString.index(baseString.startIndex, offsetBy: startPosition.offset)
        let endIndex = baseString.index(beginIndex, offsetBy: endPosition.offset - startPosition.offset)
        return beginIndex..<endIndex
    }
}
