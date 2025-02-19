//
//  OneTimeCodeItemViewType.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 19.02.2025.
//

import Foundation

@MainActor
public protocol OneTimeCodeItemViewType: AnyObject {    
    var caretRect: CGRect { get }
    var viewState: PinCodeItemViewState { get set }
    
    var valueCharacter: Character? { get set }
    var placeholderCharacter: Character? { get set }
}
