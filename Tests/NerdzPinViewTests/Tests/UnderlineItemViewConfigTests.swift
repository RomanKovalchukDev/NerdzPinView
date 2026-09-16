//
//  UnderlineItemViewConfigTests.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 16.09.2026.
//

import UIKit
import Testing
@testable import NerdzPinView

@MainActor
@Suite("Underline Item View Config")
struct UnderlineItemViewConfigTests {

    @MainActor
    @Suite("Appearance state resolution with overrides")
    struct AppearanceWithOverridesTests {

        @Test
        func testGetBackgroundColorWhenOverridesSetShouldResolvePerState() {
            // Arrange
            let config = TestData.configWithOverrides()

            // Act & Assert
            #expect(config.getBackgroundColor(for: .disabled) == TestData.defaultColor)
            #expect(config.getBackgroundColor(for: .normal) == TestData.defaultColor)
            #expect(config.getBackgroundColor(for: .active) == TestData.activeColor)
            #expect(config.getBackgroundColor(for: .error) == TestData.errorColor)
        }

        @Test
        func testGetUnderlineColorWhenOverridesSetShouldResolvePerState() {
            // Arrange
            let config = TestData.configWithOverrides()

            // Act & Assert
            #expect(config.getUnderlineColor(for: .disabled) == TestData.defaultColor)
            #expect(config.getUnderlineColor(for: .normal) == TestData.defaultColor)
            #expect(config.getUnderlineColor(for: .active) == TestData.activeColor)
            #expect(config.getUnderlineColor(for: .error) == TestData.errorColor)
        }

        @Test
        func testGetTextColorWhenOverridesSetShouldResolvePerState() {
            // Arrange
            let config = TestData.configWithOverrides()

            // Act & Assert
            #expect(config.getTextColor(for: .disabled) == TestData.defaultColor)
            #expect(config.getTextColor(for: .normal) == TestData.defaultColor)
            #expect(config.getTextColor(for: .active) == TestData.activeColor)
            #expect(config.getTextColor(for: .error) == TestData.errorColor)
        }

        @Test
        func testGetUnderlineHeightWhenOverridesSetShouldResolvePerState() {
            // Arrange
            let config = TestData.configWithOverrides()

            // Act & Assert
            #expect(config.getUnderlineHeight(for: .disabled) == TestData.defaultHeight)
            #expect(config.getUnderlineHeight(for: .normal) == TestData.defaultHeight)
            #expect(config.getUnderlineHeight(for: .active) == TestData.activeHeight)
            #expect(config.getUnderlineHeight(for: .error) == TestData.errorHeight)
        }
    }

    @MainActor
    @Suite("Appearance state resolution without overrides")
    struct AppearanceWithoutOverridesTests {

        @Test
        func testGetBackgroundColorWhenOverridesNilShouldFallBackToDefault() {
            // Arrange
            let config = TestData.configWithoutOverrides()

            // Act & Assert
            #expect(config.getBackgroundColor(for: .active) == TestData.defaultColor)
            #expect(config.getBackgroundColor(for: .error) == TestData.defaultColor)
        }

        @Test
        func testGetUnderlineColorWhenOverridesNilShouldFallBackToDefault() {
            // Arrange
            let config = TestData.configWithoutOverrides()

            // Act & Assert
            #expect(config.getUnderlineColor(for: .active) == TestData.defaultColor)
            #expect(config.getUnderlineColor(for: .error) == TestData.defaultColor)
        }

        @Test
        func testGetUnderlineHeightWhenOverridesNilShouldFallBackToDefault() {
            // Arrange
            let config = TestData.configWithoutOverrides()

            // Act & Assert
            #expect(config.getUnderlineHeight(for: .active) == TestData.defaultHeight)
            #expect(config.getUnderlineHeight(for: .error) == TestData.defaultHeight)
        }
    }

    @MainActor
    @Suite("Defaults")
    struct DefaultsTests {

        @Test
        func testAppearanceDefaultUnderlineHeightShouldMatchDocumentedDefault() {
            // Act
            let appearance = UnderlineItemView.AppearanceConfig.defaultValue

            // Assert
            #expect(appearance.defaultUnderlineHeight == 2)
        }

        @Test
        func testLayoutDefaultCornerRadiusShouldMatchDocumentedDefault() {
            // Act
            let layout = UnderlineItemView.LayoutConfig.defaultValue

            // Assert
            #expect(layout.cornerRadius == 0)
        }
    }

    @MainActor
    @Suite("Layout config round trip")
    struct LayoutConfigRoundTripTests {

        // Guards the real stored surface of LayoutConfig. The underline height is
        // intentionally NOT part of LayoutConfig (it lives in AppearanceConfig via
        // getUnderlineHeight(for:)), so every initializer argument here must land in
        // a stored property. This would surface a regression if a non-stored
        // (dropped) parameter were ever reintroduced.
        @Test
        func testInitWhenCustomValuesProvidedShouldStoreEveryProperty() {
            // Act
            let layout = UnderlineItemView.LayoutConfig(
                cursorCornerRadius: TestData.cursorCornerRadius,
                cursorHeightMultiplier: TestData.cursorHeightMultiplier,
                cursorWidth: TestData.cursorWidth,
                cornerRadius: TestData.cornerRadius,
                contentLabelEdgeInsets: TestData.contentLabelEdgeInsets
            )

            // Assert
            #expect(layout.cursorCornerRadius == TestData.cursorCornerRadius)
            #expect(layout.cursorHeightMultiplier == TestData.cursorHeightMultiplier)
            #expect(layout.cursorWidth == TestData.cursorWidth)
            #expect(layout.cornerRadius == TestData.cornerRadius)
            #expect(layout.contentLabelEdgeInsets == TestData.contentLabelEdgeInsets)
        }
    }
}

@MainActor
private enum TestData {
    static let defaultColor = UIColor(white: 0.1, alpha: 1)
    static let activeColor = UIColor(white: 0.2, alpha: 1)
    static let errorColor = UIColor(white: 0.3, alpha: 1)

    static let defaultHeight: CGFloat = 2
    static let activeHeight: CGFloat = 4
    static let errorHeight: CGFloat = 6

    static let cursorCornerRadius: CGFloat = 1.5
    static let cursorHeightMultiplier: CGFloat = 0.9
    static let cursorWidth: CGFloat = 3
    static let cornerRadius: CGFloat = 5
    static let contentLabelEdgeInsets = UIEdgeInsets(top: 4, left: 5, bottom: 6, right: 7)

    static func configWithOverrides() -> UnderlineItemView.AppearanceConfig {
        UnderlineItemView.AppearanceConfig(
            defaultBackgroundColor: defaultColor,
            activeBackgroundColor: activeColor,
            errorBackgroundColor: errorColor,
            defaultValueColor: defaultColor,
            activeValueColor: activeColor,
            errorValueColor: errorColor,
            defaultUnderlineColor: defaultColor,
            activeUnderlineColor: activeColor,
            errorUnderlineColor: errorColor,
            defaultUnderlineHeight: defaultHeight,
            activeUnderlineHeight: activeHeight,
            errorUnderlineHeight: errorHeight,
            placeholderColor: defaultColor,
            cursorColor: defaultColor
        )
    }

    static func configWithoutOverrides() -> UnderlineItemView.AppearanceConfig {
        UnderlineItemView.AppearanceConfig(
            defaultBackgroundColor: defaultColor,
            activeBackgroundColor: nil,
            errorBackgroundColor: nil,
            defaultValueColor: defaultColor,
            activeValueColor: nil,
            errorValueColor: nil,
            defaultUnderlineColor: defaultColor,
            activeUnderlineColor: nil,
            errorUnderlineColor: nil,
            defaultUnderlineHeight: defaultHeight,
            activeUnderlineHeight: nil,
            errorUnderlineHeight: nil,
            placeholderColor: defaultColor,
            cursorColor: defaultColor
        )
    }
}
