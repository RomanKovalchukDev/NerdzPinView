//
//  PinViewConfig.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

import UIKit

public struct PinViewConfig {
    public var pinLength: Int
    public var placeholderCharacter: Character?
    
    public var secureTextDelay: TimeInterval
    public var secureTextCharacter: Character
    
    public var pasteActionTitle: String
    public var pasteGestureMinDuration: TimeInterval
    
    public var shouldGroupNumbers: Bool
    public var itemSpacing: CGFloat
    public var groupSpacing: CGFloat
    
    public var shouldMoveToPreviousOnDelete: Bool
    public var shouldResignFirstResponderOnEnd: Bool
    public var shouldResignFirstResponderOnReturn: Bool
    
    public init(
        pinLength: Int = 5,
        placeholderCharacter: Character? = nil,
        secureTextCharacter: Character = "*",
        secureTextDelay: TimeInterval = 0.8,
        pasteActionTitle: String = "Paste",
        pasteGestureMinDuration: TimeInterval = 0.2,
        shouldGroupNumbers: Bool = true,
        itemSpacing: CGFloat = 10,
        groupSpacing: CGFloat = 10,
        shouldMoveToPreviousOnDelete: Bool = true,
        shouldResignFirstResponderOnEnd: Bool = true,
        shouldResignFirstResponderOnReturn: Bool = false
    ) {
        self.pinLength = pinLength
        self.placeholderCharacter = placeholderCharacter
        self.secureTextCharacter = secureTextCharacter
        self.secureTextDelay = secureTextDelay
        self.pasteActionTitle = pasteActionTitle
        self.pasteGestureMinDuration = pasteGestureMinDuration
        self.shouldGroupNumbers = shouldGroupNumbers
        self.itemSpacing = itemSpacing
        self.groupSpacing = groupSpacing
        self.shouldMoveToPreviousOnDelete = shouldMoveToPreviousOnDelete
        self.shouldResignFirstResponderOnEnd = shouldResignFirstResponderOnEnd
        self.shouldResignFirstResponderOnReturn = shouldResignFirstResponderOnReturn
    }
}
