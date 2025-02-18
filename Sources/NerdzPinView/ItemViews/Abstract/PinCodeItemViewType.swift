//
//  PinCodeItemViewType.swift
//  PinViewDemo
//
//  Created by Roman Kovalchuk on 19.11.2024.
//

import Foundation

@MainActor
public protocol PinCodeItemViewType: AnyObject {
    
    var onViewTapped: PinCodeEmptyAction? { get set }
    
    var viewState: PinCodeItemViewState { get set }
    var valueCharacter: Character? { get }
    
    var placeholderCharacter: Character? { get set }
    var secureTextCharacter: Character? { get set }
    
    var shouldSecureText: Bool { get set }
    var secureTextDelay: TimeInterval { get set }
    
    var caretRect: CGRect { get }
    
    // Animated
    func setCharacter(_ character: Character?, animated: Bool)
}
