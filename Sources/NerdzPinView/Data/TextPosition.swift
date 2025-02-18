//
//  PinTextPosition.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 14.02.2025.
//

import UIKit

public class TextPosition: UITextPosition {
    let index: Int

    init(_ index: Int) {
        self.index = index
    }

    public override var description: String {
        let props: [String] = [
            String(format: "%@: %p", NSStringFromClass(type(of: self)), self),
            "index = \(String(describing: index))",
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
