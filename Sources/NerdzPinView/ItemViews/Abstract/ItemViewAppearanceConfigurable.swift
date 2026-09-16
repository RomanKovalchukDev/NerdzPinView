//
//  ItemViewAppearanceConfigurable.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 20.11.2024.
//

/// An item view whose colors, fonts, and other visual traits are driven by a configuration value.
///
/// Container views read and assign ``appearanceConfig`` to keep every item
/// styled consistently. The associated configuration conforms to
/// ``DefaultableConfigType`` so a default styling is always available.
@MainActor
public protocol ItemViewAppearanceConfigurable: AnyObject {
    /// The concrete appearance configuration used by the conforming item view.
    associatedtype AppearanceConfig: DefaultableConfigType

    /// The appearance configuration currently applied to the item view.
    var appearanceConfig: AppearanceConfig { get set }
}
