//
//  ViewController.swift
//  NerdzPinUIKitSample
//
//  Created by Roman Kovalchuk on 16.12.2024.
//

import UIKit
import NerdzPinView

final class ViewController: UIViewController {
    
    // MARK: - Aliases
    
    public typealias PinViewType = PinCodeInputView<BorderedItemInputView>
    
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
    
    // MARK: - Properties(private)
    
    private var pinView: PinViewType = {
        let view = PinViewType()
        view.config = PinViewConfig(pinLength: 6)
        view.layoutConfig = BorderedItemInputView.LayoutConfig(cornerRadius: .zero)
        view.appearanceConfig = BorderedItemInputView.AppearanceConfig(
            defaultBackgroundColor: Constants.PinView.backgroundColor,
            activeBackgroundColor: Constants.PinView.activeBackgroundColor,
            errorBackgroundColor: Constants.PinView.errorBackgoroundColor,
            defaultValueColor: Constants.PinView.tintColor,
            activeValueColor: Constants.PinView.activeBorderColor,
            errorValueColor: Constants.PinView.errorBackgoroundColor,
            cursorColor: Constants.PinView.tintColor,
            font: Constants.PinView.font
        )
        return view
    }()
    
    private lazy var stripeField: OneTimeCodeTextField = {
        let view = OneTimeCodeTextField(configuration: .init(numberOfDigits: 6))
        return view
    }()
        
    // MARK: - IBOutlets
    
    @IBOutlet private var test: UITextField! {
        didSet {
            test.autocorrectionType = .no
            test.isSecureTextEntry = false
            test.keyboardType = .numberPad
            test.textContentType = .oneTimeCode
        }
    }
    
    @IBOutlet private var stripeContainer: UIStackView! {
        didSet {
            stripeContainer.addArrangedSubview(stripeField)
        }
    }
    
    // Example of designable bordered pin view
    @IBOutlet private var borderedPinCodeView: DesignableBorderedPinInputView! {
        didSet {
            borderedPinCodeView.config.pinLength = 10
            borderedPinCodeView.autocorrectionType = .yes
            borderedPinCodeView.isSecureTextEntry = false
            borderedPinCodeView.keyboardType = .default
            borderedPinCodeView.textContentType = .oneTimeCode
            
            borderedPinCodeView.onPinViewEnteredFully = {
                debugPrint($0, "Callback")
            }
        }
    }
    
    // Example of designable underline pin input view
    @IBOutlet private var underlinedPinCodeView: DesignableUnderlinedPinInputView! {
        didSet {
            underlinedPinCodeView.isHidden = true
        }
    }
    
    // Example of programmatically created view
    @IBOutlet private var fromCodeContainerView: UIView! {
        didSet {
            fromCodeContainerView.isHidden = true
            fromCodeContainerView.addSubview(pinView)
            
            // Make sure the view’s translatesAutoresizingMaskIntoConstraints is set to false
            pinView.translatesAutoresizingMaskIntoConstraints = false
            // Pin all edges of the `pinView` to the superview's edges
            NSLayoutConstraint.activate([
                pinView.topAnchor.constraint(equalTo: fromCodeContainerView.topAnchor),
                pinView.bottomAnchor.constraint(equalTo: fromCodeContainerView.bottomAnchor),
                pinView.leadingAnchor.constraint(equalTo: fromCodeContainerView.leadingAnchor),
                pinView.trailingAnchor.constraint(equalTo: fromCodeContainerView.trailingAnchor)
            ])
        }
    }
    
    // MARK: - IBActions
    
    @IBAction private func testButtonPressed() {
        borderedPinCodeView.insertText("111111")
    }
    
    // MARK: - Life cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        borderedPinCodeView.becomeFirstResponder()
    }
}
