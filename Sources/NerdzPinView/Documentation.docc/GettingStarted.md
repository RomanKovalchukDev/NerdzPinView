# Getting Started

Add NerdzPinView to your project.

## Installation

NerdzPinView is distributed as a Swift package. Add it to your project through Xcode with File, Add Package Dependencies, then enter the repository URL and pick the ``NerdzPinView`` library product.

You can also declare the dependency directly in a `Package.swift` manifest.

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [.iOS(.v16)],
    dependencies: [
        .package(url: "https://github.com/RomanKovalchukDev/NerdzPinView.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyApp",
            dependencies: ["NerdzPinView"]
        )
    ]
)
```

The package targets iOS 16 and later.

## Next Steps

Pick the integration that matches your app.

- <doc:SwiftUIUsage> for the SwiftUI wrappers.
- <doc:UIKitUsage> for direct use of the UIKit input views.
