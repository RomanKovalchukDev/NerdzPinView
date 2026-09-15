//
//  Aliases.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

/// A closure that reports an event carrying no associated value.
///
/// Used across the module for callbacks such as first responder changes,
/// where only the fact that the event happened matters.
public typealias PinCodeEmptyAction = () -> Void

/// A closure that reports an event carrying the current code as a string.
///
/// Used for callbacks such as value changes and completion, where the
/// latest entered value is delivered to the caller.
public typealias PinCodeTextAction = (String) -> Void
