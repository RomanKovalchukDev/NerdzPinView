//
//  ItemViewLayoutConfigurable.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 20.11.2024.
//

@MainActor
public protocol ItemViewLayoutConfigurable: AnyObject {
    associatedtype LayoutConfig: DefaultableConfigType
    var layoutConfig: LayoutConfig { get set }
}
