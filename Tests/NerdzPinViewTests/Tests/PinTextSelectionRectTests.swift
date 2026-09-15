//
//  PinTextSelectionRectTests.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 16.09.2026.
//

import UIKit
import Testing
@testable import NerdzPinView

@MainActor
@Suite("Pin Text Selection Rect")
struct PinTextSelectionRectTests {

    @Test
    func testContainsStartWhenRangeStartsAtZeroShouldReturnTrue() throws {
        // Arrange
        let range = try #require(
            PinTextRange(
                from: PinTextPosition(offset: TestData.zeroOffset),
                to: PinTextPosition(offset: TestData.midOffset)
            )
        )

        // Act
        let selectionRect = PinTextSelectionRect(rect: TestData.rect, range: range, string: TestData.baseString)

        // Assert
        #expect(selectionRect.containsStart)
    }

    @Test
    func testContainsStartWhenRangeStartsAfterZeroShouldReturnFalse() throws {
        // Arrange
        let range = try #require(
            PinTextRange(
                from: PinTextPosition(offset: TestData.midOffset),
                to: PinTextPosition(offset: TestData.endOffset)
            )
        )

        // Act
        let selectionRect = PinTextSelectionRect(rect: TestData.rect, range: range, string: TestData.baseString)

        // Assert
        #expect(selectionRect.containsStart == false)
    }

    @Test
    func testContainsEndWhenRangeEndsAtStringCountShouldReturnTrue() throws {
        // Arrange
        let range = try #require(
            PinTextRange(
                from: PinTextPosition(offset: TestData.midOffset),
                to: PinTextPosition(offset: TestData.endOffset)
            )
        )

        // Act
        let selectionRect = PinTextSelectionRect(rect: TestData.rect, range: range, string: TestData.baseString)

        // Assert
        #expect(selectionRect.containsEnd)
    }

    @Test
    func testContainsEndWhenRangeEndsBeforeStringCountShouldReturnFalse() throws {
        // Arrange
        let range = try #require(
            PinTextRange(
                from: PinTextPosition(offset: TestData.zeroOffset),
                to: PinTextPosition(offset: TestData.midOffset)
            )
        )

        // Act
        let selectionRect = PinTextSelectionRect(rect: TestData.rect, range: range, string: TestData.baseString)

        // Assert
        #expect(selectionRect.containsEnd == false)
    }

    @Test
    func testRectWhenGivenRectShouldReturnIt() throws {
        // Arrange
        let range = try #require(
            PinTextRange(
                from: PinTextPosition(offset: TestData.zeroOffset),
                to: PinTextPosition(offset: TestData.endOffset)
            )
        )

        // Act
        let selectionRect = PinTextSelectionRect(rect: TestData.rect, range: range, string: TestData.baseString)

        // Assert
        #expect(selectionRect.rect == TestData.rect)
    }

    @Test
    func testGeometryWhenCreatedShouldBeHorizontalLeftToRight() throws {
        // Arrange
        let range = try #require(
            PinTextRange(
                from: PinTextPosition(offset: TestData.zeroOffset),
                to: PinTextPosition(offset: TestData.endOffset)
            )
        )

        // Act
        let selectionRect = PinTextSelectionRect(rect: TestData.rect, range: range, string: TestData.baseString)

        // Assert
        #expect(selectionRect.isVertical == false)
        #expect(selectionRect.writingDirection == .leftToRight)
    }
}

private enum TestData {
    static let baseString = "123456"
    static let zeroOffset = 0
    static let midOffset = 3
    static let endOffset = 6
    static let rect = CGRect(x: 1, y: 2, width: 3, height: 4)
}
