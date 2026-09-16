//
//  ItemViewLayoutConfigurable.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 20.11.2024.
//

/// An item view whose sizing and geometry are driven by a configuration value.
///
/// Container views read and assign ``layoutConfig`` to keep every item laid out
/// consistently. The associated configuration conforms to
/// ``DefaultableConfigType`` so a default layout is always available.
@MainActor
public protocol ItemViewLayoutConfigurable: AnyObject {
    /// The concrete layout configuration used by the conforming item view.
    associatedtype LayoutConfig: DefaultableConfigType

    /// The layout configuration currently applied to the item view.
    var layoutConfig: LayoutConfig { get set }
}
