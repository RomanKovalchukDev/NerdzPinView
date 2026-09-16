//
//  DefaultableConfigType.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 20.11.2024.
//

/// A configuration type that provides a ready to use default value.
///
/// Item view layout and appearance configurations conform to this protocol so
/// that container views can seed themselves without requiring the caller to
/// supply a fully specified configuration.
@MainActor
public protocol DefaultableConfigType {
    /// The default configuration applied when no custom value is provided.
    static var defaultValue: Self { get }
}
