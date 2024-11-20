//
//  DefaultableConfigType.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 20.11.2024.
//

@MainActor
public protocol DefaultableConfigType {
    static var defaultValue: Self { get }
}
