//
//  PinTextRange.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 14.02.2025.
//

import UIKit

public final class TextRange: UITextRange {
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

    convenience init?(start: UITextPosition, end: UITextPosition) {
        guard
            let start = start as? TextPosition,
            let end = end as? TextPosition
        else {
            return nil
        }

        self.init(start: start, end: end)
    }

    init(start: TextPosition, end: TextPosition) {
        self._start = start
        self._end = end
    }

    public override var description: String {
        let props: [String] = [
            String(format: "%@: %p", NSStringFromClass(type(of: self)), self),
            "start = \(String(describing: _start))",
            "end = \(String(describing: _end))",
        ]
        return "<\(props.joined(separator: "; "))>"
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TextRange else {
            return false
        }

        return self._start == other._start && self._end == other._end
    }

    func contains(_ index: Int) -> Bool {
        let lowerBound = min(_start.index, _end.index)
        let upperBound = max(_start.index, _end.index)
        return index >= lowerBound && index <= upperBound
    }

    func stringRange(for string: String) -> Range<String.Index> {
        let lowerBound = min(_start.index, _end.index)
        let upperBound = max(_start.index, _end.index)

        let beginIndex = string.index(string.startIndex, offsetBy: min(lowerBound, string.count))
        let endIndex = string.index(string.startIndex, offsetBy: min(upperBound, string.count))

        return beginIndex..<endIndex
    }
}
