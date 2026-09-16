//
//  OneTimeCodeItemViewType.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.02.2025.
//

import Foundation

/// A single cell inside a ``OneTimeCodeInputView`` that renders one character of the code.
///
/// Conforming views expose the rectangle used to draw the system caret so the
/// container can position the text input cursor over the active cell. The
/// predefined conformer is ``OneTimeItemView``.
@MainActor
public protocol OneTimeCodeItemViewType: AnyObject {
    /// The rectangle, in the item view's coordinate space, where the caret is drawn.
    var caretRect: CGRect { get }

    /// The current visual state that drives colors, border, and cursor visibility.
    var viewState: PinCodeItemViewState { get set }

    /// The character currently shown in the item, or `nil` when the item is empty.
    var valueCharacter: Character? { get set }

    /// The placeholder character shown while the item has no value.
    var placeholderCharacter: Character? { get set }
}
