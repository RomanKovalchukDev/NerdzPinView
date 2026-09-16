//
//  PinCodeItemViewState.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

/// The visual state of a single item view inside a pin or one-time code input.
///
/// Item views use this state to pick the matching colors, border, and cursor
/// visibility. It is distinct from the container view state, which describes
/// the whole input rather than an individual cell.
public enum PinCodeItemViewState {
    /// The item belongs to an input that cannot receive text.
    case disabled

    /// The item is the current insertion point and shows the blinking cursor.
    case active

    /// The item is idle and neither focused nor in an error state.
    case normal

    /// The item belongs to an input that is presenting an error.
    case error
}
