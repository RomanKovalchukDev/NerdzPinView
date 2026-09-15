//
//  PinCodeItemViewType.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

import Foundation

/// A single cell inside a ``PinCodeInputView`` that renders one character of the code.
///
/// Conforming views display the current character, a placeholder, and a cursor,
/// and report taps back to the container so it can move the active position.
/// The predefined conformers are ``BorderedItemView`` and ``UnderlineItemView``.
@MainActor
public protocol PinCodeItemViewType: AnyObject {

    /// A closure invoked when the user taps the item view.
    var onViewTapped: PinCodeEmptyAction? { get set }

    /// The current visual state that drives colors, border, and cursor visibility.
    var viewState: PinCodeItemViewState { get set }

    /// The character currently shown in the item, or `nil` when the item is empty.
    var valueCharacter: Character? { get }

    /// The placeholder character shown while the item has no value.
    var placeholderCharacter: Character? { get set }

    /// The character substituted for the real value when secure entry is on.
    var secureTextCharacter: Character? { get set }

    /// A Boolean value indicating whether the real value is masked by the secure character.
    var shouldSecureText: Bool { get set }

    /// The delay before the visible character is replaced by the secure character.
    var secureTextDelay: TimeInterval { get set }

    /// Sets the displayed character, optionally animating the transition to the secure character.
    ///
    /// - Parameters:
    ///   - character: The character to display, or `nil` to clear the item.
    ///   - animated: Whether to briefly show the real character before masking it. Only relevant when secure entry is on.
    func setCharacter(_ character: Character?, animated: Bool)
}
