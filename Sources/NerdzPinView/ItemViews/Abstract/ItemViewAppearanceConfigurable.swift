//
//  ItemViewAppearanceConfigurable.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 20.11.2024.
//

@MainActor
public protocol ItemViewAppearanceConfigurable: AnyObject {
    associatedtype AppearanceConfig: DefaultableConfigType
    var appearanceConfig: AppearanceConfig { get set }
}
