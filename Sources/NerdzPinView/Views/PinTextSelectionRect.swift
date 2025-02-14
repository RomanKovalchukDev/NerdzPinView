//
//  PinTextSelectionRect.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 14.02.2025.
//

import UIKit

public class PinTextSelectionRect: UITextSelectionRect {
    private let _rect: CGRect
    private let _containsStart: Bool
    private let _containsEnd: Bool
    
    public override var writingDirection: NSWritingDirection {
        .leftToRight
    }
    
    public override var isVertical: Bool {
        false
    }
    
    public override var rect: CGRect {
        _rect
    }
    
    public override var containsStart: Bool {
        _containsStart
    }
    
    public override var containsEnd: Bool {
        _containsEnd
    }
    
    init(rect: CGRect, range: PinTextRange, string: String) {
        _rect = rect
        _containsStart = range.startPosition.offset == 0
        _containsEnd = range.endPosition.offset == string.count
    }
}
