//
//  ViewController.swift
//  NerdzPinUIKitSample
//
//  Created by Roman Kovalchuk on 16.12.2024.
//

import UIKit
import NerdzPinView

final class ViewController: UIViewController {
    
    // MARK: - Internal types

    private enum Constants {
        enum PinView {
            static let pinLength: Int = 6
            static let font = UIFont.systemFont(ofSize: 14)
            static let backgroundColor = UIColor.lightGray
            static let activeBackgroundColor = UIColor.white
            static let errorBackgoroundColor = UIColor.white
            static let defaultBorderColor = backgroundColor
            static let activeBorderColor = UIColor.green
            static let errorBorderColor = UIColor.systemRed
            static let borderWidth: CGFloat = 1
            static let tintColor = UIColor.black
        }
    }
        
    // MARK: - IBOutlets
    
    // Example of designable bordered pin view
    @IBOutlet private var borderedPinCodeView: DesignableBorderedPinInputView! {
        didSet {
            borderedPinCodeView.onPinValueChanged = {
                debugPrint("Pin value changed: \($0)")
            }
            
            borderedPinCodeView.onPinViewEnteredFully = {
                debugPrint("Pin code entered fully: \($0)")
            }
        }
    }
    
    // Example of designable underline pin input view
    @IBOutlet private var underlinedPinCodeView: DesignableUnderlinedPinInputView!
    
    @IBOutlet private var oneTimeCodeInputView: DesignableOneTimeCodeInputView! {
        didSet {
            oneTimeCodeInputView.onPinViewEnteredFully = {
                debugPrint("OTP entered fully: \($0)")
            }
        }
    }
    
    // MARK: - Life cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        borderedPinCodeView.becomeFirstResponder()
    }
}
