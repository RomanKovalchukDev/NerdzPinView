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
    
    // If content is centered - stack view would take located in center of the view / otherwise would be stretched
    public var isContentCentered: Bool
    public var containerSpacing: CGFloat
    
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
        isContentCentered: Bool = true,
        containerSpacing: CGFloat = 10,
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
        self.isContentCentered = isContentCentered
        self.containerSpacing = containerSpacing
        self.shouldMoveToPreviousOnDelete = shouldMoveToPreviousOnDelete
        self.shouldResignFirstResponderOnEnd = shouldResignFirstResponderOnEnd
        self.shouldResignFirstResponderOnReturn = shouldResignFirstResponderOnReturn
    }
}
