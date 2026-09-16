# SwiftUI Usage

Present a pin input in SwiftUI with the ready to use wrappers.

## Overview

Use ``NerdzBorderedPinView`` (or ``NerdzUnderlinePinView`` for the underlined style). It needs three bindings. One for the entered ``NerdzBorderedPinView/text``, one for the ``NerdzBorderedPinView/viewState``, and a `FocusState` binding for the keyboard focus.

```swift
import SwiftUI
import NerdzPinView

struct VerificationView: View {
    @State private var code: String = ""
    @State private var pinState: NerdzBorderedPinView.ViewState = .normal
    @FocusState private var isFocused: Bool

    var body: some View {
        NerdzBorderedPinView(
            text: $code,
            viewState: $pinState,
            isFocused: $isFocused,
            onPinViewEnteredFully: { enteredCode in
                verify(enteredCode)
            }
        )
        .frame(height: 56)
        .onAppear {
            isFocused = true
        }
    }

    private func verify(_ enteredCode: String) {
        // Validate the code, then reflect the result in the state.
        pinState = enteredCode == "123456" ? .normal : .error
    }
}
```

The ``NerdzBorderedPinView/onPinViewEnteredFully`` closure fires once every cell is filled. Drive the ``NerdzBorderedPinView/viewState`` binding to `.error` to highlight an invalid code, or to `.disabled` to block further input.

## Customizing the Appearance

Pass a ``BorderedItemView/AppearanceConfig`` and a ``BorderedItemView/LayoutConfig`` (or the underline equivalents) to the initializer to change colors, fonts, and metrics. Pass a ``NerdzBorderedPinView/ViewConfig`` to adjust behavior such as the number of characters.

```swift
NerdzBorderedPinView(
    text: $code,
    viewState: $pinState,
    isFocused: $isFocused,
    config: .init(pinLength: 4),
    itemsAppearanceConfig: BorderedItemView.AppearanceConfig(
        defaultBorderColor: .systemGray,
        activeBorderColor: .systemBlue,
        font: .systemFont(ofSize: 20, weight: .semibold)
    )
)
```

## See Also

- <doc:GettingStarted>
- <doc:UIKitUsage>
- ``NerdzUnderlinePinView``
