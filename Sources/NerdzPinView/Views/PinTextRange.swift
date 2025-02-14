//
//  PinTextRange.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 14.02.2025.
//

import UIKit

open class PinTextRange: UITextRange {
    
    public let startPosition: PinTextPosition
    public let endPosition: PinTextPosition
    
    public var length: Int {
        endPosition.offset - startPosition.offset
    }
    
    public override var description: String {
        "[\(startPosition.offset) ..< \(endPosition.offset)]"
    }
    
    public override var start: UITextPosition {
        startPosition
    }
    
    public override var end: UITextPosition {
        endPosition
    }
    
    public override var isEmpty: Bool {
        startPosition.offset >= endPosition.offset
    }
    
    // from may be larger than to
    // from and to must each contain a valid indices
    public init?(from: PinTextPosition, to: PinTextPosition) {
        guard from.offset < to.offset else {
            return nil
        }
        
        self.startPosition = from
        self.endPosition = to
    }
    
    // maxLength may be negative
    // from must contain a valid index
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
    
    public func fullRange(in baseString: String) -> Range<String.Index> {
        let beginIndex = baseString.index(baseString.startIndex, offsetBy: startPosition.offset)
        let endIndex = baseString.index(beginIndex, offsetBy: endPosition.offset - startPosition.offset)
        return beginIndex..<endIndex
    }
}
