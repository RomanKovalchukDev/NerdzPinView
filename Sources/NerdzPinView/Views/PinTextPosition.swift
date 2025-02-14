//
//  PinTextPosition.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 14.02.2025.
//

import UIKit

public class PinTextPosition: UITextPosition {
    public let offset: Int
    
    public override var description: String {
        "\(offset)"
    }
    
    public init(offset: Int) {
        self.offset = offset
    }
}
