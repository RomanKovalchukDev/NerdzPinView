# Using the UIKit Input Views

Embed a pin or one-time code input directly in a view controller.

## Overview

The SwiftUI wrappers are built on top of two generic UIKit containers, and you can use those containers directly. ``PinCodeInputView`` is a `UIKeyInput` based row of tappable cells, and ``OneTimeCodeInputView`` is a `UITextInput` based field that supports the system caret and one-time code autofill. Both are generic over an item view type, so you specialize them with one of the predefined item views such as ``BorderedItemView``, ``UnderlineItemView``, or ``OneTimeItemView``.

## PinCodeInputView

Specialize ``PinCodeInputView`` with an item view, configure it, then add it to your hierarchy. Call `becomeFirstResponder()` to raise the keyboard.

```swift
import UIKit
import NerdzPinView

final class PinViewController: UIViewController {

    private let pinView = PinCodeInputView<BorderedItemView>()

    override func viewDidLoad() {
        super.viewDidLoad()

        pinView.config = PinCodeInputView<BorderedItemView>.PinViewConfig(pinLength: 6)
        pinView.appearanceConfig = BorderedItemView.AppearanceConfig(
            font: .systemFont(ofSize: 18, weight: .medium)
        )

        pinView.onPinValueChanged = { value in
            print("Current value: \(value)")
        }

        pinView.onPinViewEnteredFully = { value in
            print("Completed: \(value)")
        }

        pinView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pinView)

        NSLayoutConstraint.activate([
            pinView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pinView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            pinView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            pinView.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        pinView.becomeFirstResponder()
    }
}
```

Set ``PinCodeInputView/viewState`` to `.error` to highlight an invalid entry, and use ``PinCodeInputView/setText(_:)`` to prefill or clear the value without triggering the change callbacks.

## OneTimeCodeInputView

``OneTimeCodeInputView`` works the same way, specialized with ``OneTimeItemView``. Because it conforms to `UITextInput`, it participates in one-time code autofill and can group the cells into two halves.

```swift
let codeView = OneTimeCodeInputView<OneTimeItemView>()

codeView.config = OneTimeCodeInputView<OneTimeItemView>.Config(
    pinLength: 6,
    shouldGroupNumbers: true
)
codeView.appearanceConfig = OneTimeItemView.AppearanceConfig(
    font: .systemFont(ofSize: 18, weight: .medium)
)

codeView.onPinViewEnteredFully = { value in
    print("Completed: \(value)")
}
```

Read the entered characters at any time through ``OneTimeCodeInputView/value``.

## Using the Pre-Styled Wrappers

If you do not need to pick the item type yourself, the designable wrappers apply a default styling and expose the same callbacks and configuration. Use ``DesignableBorderedPinInputView``, ``DesignableUnderlinedPinInputView``, or ``DesignableOneTimeCodeInputView``. These are also the views the SwiftUI wrappers bridge to.

## See Also

- <doc:GettingStarted>
- ``PinCodeInputView``
- ``OneTimeCodeInputView``
