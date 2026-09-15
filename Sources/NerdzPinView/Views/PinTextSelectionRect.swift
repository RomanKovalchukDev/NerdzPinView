//
//  PinTextSelectionRect.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 14.02.2025.
//

import UIKit

/// A selection rectangle describing part of a pin code selection.
///
/// This is the module's concrete `UITextSelectionRect`. Pin inputs are always
/// laid out left to right and horizontally, so the writing direction and
/// orientation are fixed.
public class PinTextSelectionRect: UITextSelectionRect {
    private let _rect: CGRect
    private let _containsStart: Bool
    private let _containsEnd: Bool

    /// The writing direction of the selection, always left to right.
    public override var writingDirection: NSWritingDirection {
        .leftToRight
    }

    /// A Boolean value indicating whether the selection is vertical, always `false`.
    public override var isVertical: Bool {
        false
    }

    /// The rectangle, in the input view's coordinate space, covered by the selection.
    public override var rect: CGRect {
        _rect
    }

    /// A Boolean value indicating whether the rectangle contains the start of the selection.
    public override var containsStart: Bool {
        _containsStart
    }

    /// A Boolean value indicating whether the rectangle contains the end of the selection.
    public override var containsEnd: Bool {
        _containsEnd
    }
    
    init(rect: CGRect, range: PinTextRange, string: String) {
        _rect = rect
        _containsStart = range.startPosition.offset == 0
        _containsEnd = range.endPosition.offset == string.count
    }
}
