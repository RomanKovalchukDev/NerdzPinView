//
//  PinCodeInputViewTests.swift
//  NerdzPinView
//

import UIKit
import Testing
@testable import NerdzPinView

@MainActor
@Suite("Pin Code Input View")
struct PinCodeInputViewTests {

    @MainActor
    @Suite("Accessibility")
    struct AccessibilityTests {

        @Test
        func testInitShouldBeTheSingleAccessibilityElement() {
            // Arrange
            let sut = TestData.makeSut()

            // Assert
            #expect(sut.isAccessibilityElement)
        }

        @Test
        func testConfigureSubviewsShouldHideItemViewsFromAccessibility() {
            // Arrange
            let sut = TestData.makeSut()

            // Act
            let itemViews = sut.subviews.flatMap({ $0.subviews })

            // Assert
            #expect(!itemViews.isEmpty)
            #expect(itemViews.allSatisfy({ !$0.isAccessibilityElement }))
        }

        @Test
        func testAccessibilityValueShouldMirrorText() {
            // Arrange
            let sut = TestData.makeSut()

            // Act
            sut.setText("AB")

            // Assert
            #expect(sut.accessibilityValue == sut.text)
        }

        @Test
        func testAccessibilityActivateShouldBecomeFirstResponder() {
            // Arrange
            let sut = TestData.makeSut()
            TestData.attachToWindow(sut)

            // Act
            let didActivate = sut.accessibilityActivate()

            // Assert
            #expect(didActivate)
            #expect(sut.isFirstResponder)
        }
    }

    @MainActor
    @Suite("Paste gesture suppression")
    struct PasteGestureTests {

        @Test
        func testCanPerformActionWhenPasteGestureEnabledAndPasteboardHasStringShouldReturnTrue() {
            // Arrange
            let sut = TestData.makeSut(isPasteGestureEnabled: true)
            UIPasteboard.general.string = TestData.pasteboardString

            // Act & Assert
            #expect(sut.canPerformAction(#selector(UIResponderStandardEditActions.paste(_:)), withSender: nil))
        }

        @Test
        func testCanPerformActionWhenPasteGestureDisabledShouldReturnFalseEvenWithPasteboardString() {
            // Arrange
            let sut = TestData.makeSut(isPasteGestureEnabled: false)
            UIPasteboard.general.string = TestData.pasteboardString

            // Act & Assert
            #expect(!sut.canPerformAction(#selector(UIResponderStandardEditActions.paste(_:)), withSender: nil))
        }

        @Test
        func testLongPressGestureWhenPasteGestureDisabledShouldBeDisabled() {
            // Arrange
            let sut = TestData.makeSut(isPasteGestureEnabled: false)

            // Act
            let longPressGesture = TestData.longPressGesture(of: sut)

            // Assert
            #expect(longPressGesture?.isEnabled == false)
        }

        @Test
        func testLongPressGestureWhenPasteGestureEnabledShouldBeEnabled() {
            // Arrange
            let sut = TestData.makeSut(isPasteGestureEnabled: true)

            // Act
            let longPressGesture = TestData.longPressGesture(of: sut)

            // Assert
            #expect(longPressGesture?.isEnabled == true)
        }
    }

    @MainActor
    @Suite("Delete at start")
    struct DeleteAtStartTests {

        @Test
        func testDeleteBackwardWhenFirstItemAlreadyEmptyShouldInvokeOnDeleteAtStart() {
            // Arrange
            let sut = TestData.makeSut()
            var didInvoke = false
            sut.onDeleteAtStart = { didInvoke = true }
            sut.becomeFirstResponder()

            // Act
            sut.deleteBackward()

            // Assert
            #expect(didInvoke)
        }

        @Test
        func testDeleteBackwardWhenMovingFromALaterEmptyItemShouldNotInvokeOnDeleteAtStart() {
            // Arrange: item 0 holds "A", active item moved to the (empty) item 1
            let sut = TestData.makeSut()
            var didInvoke = false
            sut.onDeleteAtStart = { didInvoke = true }
            sut.becomeFirstResponder()
            sut.insertText("A")

            // Act: clears empty item 1, moving the active item back to item 0
            sut.deleteBackward()

            // Assert
            #expect(!didInvoke)
        }

        @Test
        func testDeleteBackwardWhenFirstItemHasValueShouldNotInvokeOnDeleteAtStart() {
            // Arrange: item 0 holds "A"; one backspace already moved the active item back to it
            let sut = TestData.makeSut()
            var didInvoke = false
            sut.onDeleteAtStart = { didInvoke = true }
            sut.becomeFirstResponder()
            sut.insertText("A")
            sut.deleteBackward()

            // Act: clears item 0's own value
            sut.deleteBackward()

            // Assert
            #expect(!didInvoke)
        }
    }
}

@MainActor
private enum TestData {
    static let pasteboardString = "ABCD1234"

    static func makeSut(isPasteGestureEnabled: Bool = true) -> PinCodeInputView<BorderedItemView> {
        let sut = PinCodeInputView<BorderedItemView>()
        sut.config = PinCodeInputView<BorderedItemView>.PinViewConfig(pinLength: 4, isPasteGestureEnabled: isPasteGestureEnabled)
        return sut
    }

    static func attachToWindow(_ view: UIView) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.addSubview(view)
        window.makeKeyAndVisible()
    }

    /// The long press gesture lives on the item container, a subview of the input, not the input itself.
    static func longPressGesture(of sut: PinCodeInputView<BorderedItemView>) -> UIGestureRecognizer? {
        sut.subviews.first?.gestureRecognizers?.first(where: { $0 is UILongPressGestureRecognizer })
    }
}
