//
//  PinViewConfig.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

import UIKit

public struct PinViewConfig {
    var pinLength: Int
    var placeholderCharacter: Character?
    
    var secureTextDelay: TimeInterval
    var secureTextCharacter: Character
    
    // If content is centered - stack view would take located in center of the view / otherwise would be stretched
    let isContentCentered: Bool
    var containerSpacing: CGFloat
    
    var shouldMoveToPreviousOnDelete: Bool
    var shouldResignFirstResponderOnEnd: Bool
    var shouldResignFirstResponderOnReturn: Bool
    
    init(
        pinLength: Int = 5,
        placeholderCharacter: Character? = nil,
        secureTextCharacter: Character = "*",
        secureTextDelay: TimeInterval = 0.8,
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
        self.isContentCentered = isContentCentered
        self.containerSpacing = containerSpacing
        self.shouldMoveToPreviousOnDelete = shouldMoveToPreviousOnDelete
        self.shouldResignFirstResponderOnEnd = shouldResignFirstResponderOnEnd
        self.shouldResignFirstResponderOnReturn = shouldResignFirstResponderOnReturn
    }
}
