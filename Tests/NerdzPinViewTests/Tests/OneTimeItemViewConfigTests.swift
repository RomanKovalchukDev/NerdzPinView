//
//  OneTimeItemViewConfigTests.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 16.09.2026.
//

import UIKit
import Testing
@testable import NerdzPinView

@MainActor
@Suite("One Time Item View Config")
struct OneTimeItemViewConfigTests {

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
        func testGetBorderColorWhenOverridesSetShouldResolvePerState() {
            // Arrange
            let config = TestData.configWithOverrides()

            // Act & Assert
            #expect(config.getBorderColor(for: .disabled) == TestData.defaultColor)
            #expect(config.getBorderColor(for: .normal) == TestData.defaultColor)
            #expect(config.getBorderColor(for: .active) == TestData.activeColor)
            #expect(config.getBorderColor(for: .error) == TestData.errorColor)
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
        func testGetBorderWidthWhenOverridesSetShouldResolvePerState() {
            // Arrange
            let config = TestData.configWithOverrides()

            // Act & Assert
            #expect(config.getBorderWidth(for: .disabled) == TestData.defaultWidth)
            #expect(config.getBorderWidth(for: .normal) == TestData.defaultWidth)
            #expect(config.getBorderWidth(for: .active) == TestData.activeWidth)
            #expect(config.getBorderWidth(for: .error) == TestData.errorWidth)
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
        func testGetBorderColorWhenOverridesNilShouldFallBackToDefault() {
            // Arrange
            let config = TestData.configWithoutOverrides()

            // Act & Assert
            #expect(config.getBorderColor(for: .active) == TestData.defaultColor)
            #expect(config.getBorderColor(for: .error) == TestData.defaultColor)
        }

        @Test
        func testGetTextColorWhenOverridesNilShouldFallBackToDefault() {
            // Arrange
            let config = TestData.configWithoutOverrides()

            // Act & Assert
            #expect(config.getTextColor(for: .active) == TestData.defaultColor)
            #expect(config.getTextColor(for: .error) == TestData.defaultColor)
        }

        @Test
        func testGetBorderWidthWhenOverridesNilShouldFallBackToDefault() {
            // Arrange
            let config = TestData.configWithoutOverrides()

            // Act & Assert
            #expect(config.getBorderWidth(for: .active) == TestData.defaultWidth)
            #expect(config.getBorderWidth(for: .error) == TestData.defaultWidth)
        }
    }

    @MainActor
    @Suite("Defaults")
    struct DefaultsTests {

        @Test
        func testLayoutDefaultValueShouldMatchDocumentedDefaults() {
            // Act
            let layout = OneTimeItemView.LayoutConfig.defaultValue

            // Assert
            #expect(layout.itemHeight == 50)
            #expect(layout.cornerRadius == 8)
        }
    }
}

@MainActor
private enum TestData {
    static let defaultColor = UIColor(white: 0.1, alpha: 1)
    static let activeColor = UIColor(white: 0.2, alpha: 1)
    static let errorColor = UIColor(white: 0.3, alpha: 1)

    static let defaultWidth: CGFloat = 1
    static let activeWidth: CGFloat = 2
    static let errorWidth: CGFloat = 3

    static func configWithOverrides() -> OneTimeItemView.AppearanceConfig {
        OneTimeItemView.AppearanceConfig(
            defaultBackgroundColor: defaultColor,
            activeBackgroundColor: activeColor,
            errorBackgroundColor: errorColor,
            defaultValueColor: defaultColor,
            activeValueColor: activeColor,
            errorValueColor: errorColor,
            placeholderColor: defaultColor,
            defaultBorderColor: defaultColor,
            activeBorderColor: activeColor,
            errorBorderColor: errorColor,
            defaultBorderWidth: defaultWidth,
            activeBorderWidth: activeWidth,
            errorBorderWidth: errorWidth,
            cursorColor: defaultColor
        )
    }

    static func configWithoutOverrides() -> OneTimeItemView.AppearanceConfig {
        OneTimeItemView.AppearanceConfig(
            defaultBackgroundColor: defaultColor,
            activeBackgroundColor: nil,
            errorBackgroundColor: nil,
            defaultValueColor: defaultColor,
            activeValueColor: nil,
            errorValueColor: nil,
            placeholderColor: defaultColor,
            defaultBorderColor: defaultColor,
            activeBorderColor: nil,
            errorBorderColor: nil,
            defaultBorderWidth: defaultWidth,
            activeBorderWidth: nil,
            errorBorderWidth: nil,
            cursorColor: defaultColor
        )
    }
}
