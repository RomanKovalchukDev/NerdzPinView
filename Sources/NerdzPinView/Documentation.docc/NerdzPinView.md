# ``NerdzPinView``

Customizable pin code and one-time code input views for UIKit, with ready to use SwiftUI wrappers.

## Overview

NerdzPinView provides styled, multi-cell code entry components for iOS. At its core are two generic UIKit containers. ``PinCodeInputView`` drives a row of tappable item cells through `UIKeyInput`, while ``OneTimeCodeInputView`` implements the full `UITextInput` protocol so it supports the system caret and one-time code autofill. Each container is parameterized by an item view type, and the module ships bordered, underlined, and grouped item views out of the box.

For most apps the pre-styled wrappers are enough. ``DesignableBorderedPinInputView``, ``DesignableUnderlinedPinInputView``, and ``DesignableOneTimeCodeInputView`` bundle sensible defaults, and ``NerdzBorderedPinView`` and ``NerdzUnderlinePinView`` expose that behavior to SwiftUI through bindings for the text, the state, and the keyboard focus.

To get started, read <doc:GettingStarted>, then <doc:SwiftUIUsage> for SwiftUI or <doc:UIKitUsage> for UIKit.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:SwiftUIUsage>
- <doc:UIKitUsage>

### SwiftUI Views

- ``NerdzBorderedPinView``
- ``NerdzUnderlinePinView``

### UIKit Input Views

- ``PinCodeInputView``
- ``OneTimeCodeInputView``
- ``DesignableBorderedPinInputView``
- ``DesignableUnderlinedPinInputView``
- ``DesignableOneTimeCodeInputView``
- ``PinTapableView``

### Item Views

- ``BorderedItemView``
- ``UnderlineItemView``
- ``OneTimeItemView``

### Item View Protocols

- ``PinCodeItemViewType``
- ``OneTimeCodeItemViewType``
- ``PinCodeItemView``
- ``OneTimeCodeItemView``

### Configuration

- ``DefaultableConfigType``
- ``ItemViewAppearanceConfigurable``
- ``ItemViewLayoutConfigurable``
- ``PinCodeItemViewState``

### Text Input Primitives

- ``PinTextPosition``
- ``PinTextRange``
- ``PinTextSelectionRect``

### Callbacks

- ``PinCodeEmptyAction``
- ``PinCodeTextAction``
