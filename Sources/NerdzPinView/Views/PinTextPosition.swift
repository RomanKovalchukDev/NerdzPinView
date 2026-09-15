//
//  PinTextPosition.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 14.02.2025.
//

import UIKit

/// A position inside a pin code string, expressed as a character offset.
///
/// This is the module's concrete `UITextPosition` used by the `UITextInput`
/// conformances to describe caret locations and range endpoints.
public class PinTextPosition: UITextPosition {
    /// The zero based character offset represented by this position.
    public let offset: Int

    /// A textual representation of the position, used for debugging.
    public override var description: String {
        "\(offset)"
    }

    /// Creates a position at the given character offset.
    ///
    /// - Parameter offset: The zero based character offset.
    public init(offset: Int) {
        self.offset = offset
    }
}
