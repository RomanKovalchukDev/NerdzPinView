# NerdzPinView

NerdzPinView is a highly customisable library used for entering pin and one time codes.

[![Swift 5.9](https://img.shields.io/badge/Swift-5.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![SPM Compatible](https://img.shields.io/badge/Swift%20Package%20Manager-8A2BE2)](https://www.swift.org/documentation/package-manager/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](http://www.apple.com/ios/)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://opensource.org/licenses/MIT)

## Getting Started

NerdzPinView library supports both UIKIt and SwiftUI frameworks. 

## Installation

### Swift Package Manager

To add NerdzPinView to a Swift Package Manager based project add it using Xcode add package command or add it as a dependency inside your `Package.swift` file:
```.package(url: "https://github.com/RomanKovalchukDev/NerdzPinView")```

### Manual

Clone the repo and drag files from `NerdzPinView/Sources` folder into your Xcode project.

## Usage

### SwiftUI

NerdzPinView provides ready to use SwiftUI wrappers over the underlying `UIKeyInput` component. Drop `NerdzBorderedPinView` or `NerdzUnderlinePinView` into your view body and bind the text, view state, and focus state. A typical setup looks like the snippet below.

```swift
import SwiftUI
import NerdzPinView

struct LoginView: View {
    @State private var code: String = ""
    @State private var viewState: NerdzBorderedPinView.ViewState = .normal
    @FocusState private var isFocused: Bool

    var body: some View {
        NerdzBorderedPinView(
            text: $code,
            viewState: $viewState,
            isFocused: $isFocused,
            onPinViewEnteredFully: { value in
                submit(code: value)
            }
        )
        .frame(height: 50)
        .padding(.horizontal)
    }
}
```

`NerdzBorderedPinView` and `NerdzUnderlinePinView` share the same public surface. The most important pieces are:

* `text: Binding<String>` receives every keystroke and lets you drive the view from external state (for example to clear it after a failed verification).
* `viewState: Binding<ViewState>` controls the visual state (`.normal`, `.error`, `.disabled`).
* `isFocused: FocusState<Bool>.Binding` lets SwiftUI manage the keyboard the same way it does for `TextField`.
* `onPinViewEnteredFully: ((String) -> Void)?` fires once the user has typed `config.pinLength` characters.

All of the `UIKeyInput` configuration (keyboard type, autocorrection, content type, secure entry, etc.) is exposed as initializer parameters with sensible defaults.

You can also browse the [SwiftUI demo project](https://github.com/RomanKovalchukDev/NerdzPinView/tree/main/Samples/NerdzPinSwiftUISample).

### Configuration

Each view accepts three configuration objects, all of them plain Swift structs. Every property in their initializers has a default value, so you can override only the ones you care about and leave the rest at the library defaults.

```swift
NerdzBorderedPinView(
    text: $code,
    viewState: $viewState,
    isFocused: $isFocused,
    config: .init(
        pinLength: 6,
        isContentCentered: true,
        containerSpacing: 12
    ),
    itemsLayoutConfig: .init(cornerRadius: 12),
    itemsAppearanceConfig: .init(
        defaultBackgroundColor: .systemGray6,
        activeBorderColor: .systemBlue,
        errorBorderColor: .systemRed,
        cursorColor: .label,
        font: .systemFont(ofSize: 18, weight: .semibold)
    )
)
```

The three configs are:

* `PinViewConfig` (top level) covers behavior: pin length, placeholder character, secure text presentation, paste handling, layout policy (`isContentCentered`, `containerSpacing`), delete behavior, and whether the field should resign first responder on completion or return.
* `LayoutConfig` (per item) covers geometry: corner radius, cursor size, content insets.
* `AppearanceConfig` (per item) covers colors and the font, with separate slots for the `.normal`, `.active`, and `.error` states. Any state specific color left as `nil` falls back to the default color, so you can light up only the states you care about.

If you want a single property changed on top of an existing config, you can also build it from an existing value using normal Swift struct copy semantics:

```swift
var appearance = BorderedItemView.AppearanceConfig.defaultValue
appearance.activeBorderColor = .systemBlue
appearance.cursorColor = .systemBlue
```

### Layout sizing

The items are always rendered as squares, sized to the height of the view. The view will fit `pinLength` squares plus `containerSpacing * (pinLength - 1)` of horizontal space at the current height. Apply a `.frame(height:)` (or any equivalent height constraint) and make sure the available width can hold that many squares. If the width is tighter, the items shrink uniformly and stay centered.

### UIKit

For storyboards and xibs, use the prebuilt `DesignableBorderedPinInputView` or `DesignableUnderlinedPinInputView`. They wrap the same generic `PinCodeInputView` used by the SwiftUI components and expose the same configuration objects (`config`, `layoutConfig`, `appearanceConfig`) as settable properties.

For full control (for example to plug in a custom item view), use the generic `PinCodeInputView<T: PinCodeItemView>` directly. Implement `PinCodeItemViewType`, `ItemViewLayoutConfigurable`, and `ItemViewAppearanceConfigurable` on your custom item to participate in the same configuration pipeline.

You can also browse the [UIKit demo project](https://github.com/RomanKovalchukDev/NerdzPinView/tree/main/Samples/NerdzPinUIKitSample).

## Requirements

- iOS 16.0 +
- Xcode 16.0 +

## License

NerdzPinView is available under the MIT license. See LICENSE for details.
