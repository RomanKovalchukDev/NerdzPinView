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

NerdzPinView library provides complete SwiftUI wrapper over custom UIKeyInput component. To use it inside your SwiftUI application just add `NerdzBorderedPinView` or `NerdzUnderlinePinView` inside your view body.
SwiftUI views have `text`, `viewState`, and `isFocused` binding properties alongside UIKeyInput properties that are passed to the wrapped view. 

You could take a look into the usage of the library inside SwiftUI project using [SwiftUI demo project](https://github.com/RomanKovalchukDev/NerdzPinView/tree/main/Samples/NerdzPinSwiftUISample).

### UIKit

To use the library from the xib files or storyboards you should use `DesignableBorderedPinInputView` or `DesignableUnderlinedPinInputView` - this two classes are predefined views that are wrapers around generic `PinCodeInputView`.

You could also use generic `PinCodeInputView` programatically. This use case mostly needed for you to provide your own item display view. 

You could take a look into the usage of the library inside SwiftUI project using [SwiftUI demo project](https://github.com/RomanKovalchukDev/NerdzPinView/tree/main/Samples//NerdzPinUIKitSample).

## Requirements

- iOS 16.0 +
- Xcode 16.0 +

## License

NerdzPinView is available under the MIT license. See LICENSE for details.
