//
//  PinTextRangeTests.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 16.09.2026.
//

import Testing
@testable import NerdzPinView

@Suite("Pin Text Range")
struct PinTextRangeTests {

    @MainActor
    @Suite("Init from/to")
    struct InitFromToTests {

        @Test
        func testInitWhenFromLessThanToShouldStorePositions() throws {
            // Arrange
            let from = PinTextPosition(offset: TestData.lowerOffset)
            let to = PinTextPosition(offset: TestData.upperOffset)

            // Act
            let range = try #require(PinTextRange(from: from, to: to))

            // Assert
            #expect(range.startPosition.offset == TestData.lowerOffset)
            #expect(range.endPosition.offset == TestData.upperOffset)
        }

        @Test
        func testInitWhenFromEqualsToShouldReturnNil() {
            // Arrange
            let position = PinTextPosition(offset: TestData.lowerOffset)

            // Act
            let range = PinTextRange(from: position, to: PinTextPosition(offset: TestData.lowerOffset))

            // Assert
            #expect(range == nil)
        }

        @Test
        func testInitWhenFromGreaterThanToShouldReturnNil() {
            // Arrange
            let from = PinTextPosition(offset: TestData.upperOffset)
            let to = PinTextPosition(offset: TestData.lowerOffset)

            // Act
            let range = PinTextRange(from: from, to: to)

            // Assert
            #expect(range == nil)
        }
    }

    @MainActor
    @Suite("Init from/maxOffset")
    struct InitMaxOffsetTests {

        @Test
        func testInitWhenPositiveOffsetWithinBoundsShouldExtendForward() {
            // Arrange
            let from = PinTextPosition(offset: TestData.lowerOffset)
            let maxOffset = TestData.smallMaxOffset

            // Act
            let range = PinTextRange(from: from, maxOffset: maxOffset, in: TestData.baseString)

            // Assert
            #expect(range.startPosition.offset == TestData.lowerOffset)
            #expect(range.endPosition.offset == TestData.lowerOffset + maxOffset)
        }

        @Test
        func testInitWhenPositiveOffsetExceedsLengthShouldClampToStringCount() {
            // Arrange
            let from = PinTextPosition(offset: TestData.lowerOffset)

            // Act
            let range = PinTextRange(from: from, maxOffset: TestData.hugeMaxOffset, in: TestData.baseString)

            // Assert
            #expect(range.endPosition.offset == TestData.baseString.count)
        }

        @Test
        func testInitWhenNegativeOffsetWithinBoundsShouldExtendBackward() {
            // Arrange
            let from = PinTextPosition(offset: TestData.upperOffset)
            let maxOffset = TestData.negativeMaxOffset

            // Act
            let range = PinTextRange(from: from, maxOffset: maxOffset, in: TestData.baseString)

            // Assert
            #expect(range.startPosition.offset == TestData.upperOffset + maxOffset)
            #expect(range.endPosition.offset == TestData.upperOffset)
        }

        @Test
        func testInitWhenNegativeOffsetBelowZeroShouldClampToZero() {
            // Arrange
            let from = PinTextPosition(offset: TestData.lowerOffset)

            // Act
            let range = PinTextRange(from: from, maxOffset: TestData.hugeNegativeMaxOffset, in: TestData.baseString)

            // Assert
            #expect(range.startPosition.offset == 0)
            #expect(range.endPosition.offset == TestData.lowerOffset)
        }
    }

    @MainActor
    @Suite("Derived properties")
    struct DerivedPropertyTests {

        @Test
        func testLengthWhenRangeSpansPositionsShouldReturnDifference() throws {
            // Arrange
            let from = PinTextPosition(offset: TestData.lowerOffset)
            let to = PinTextPosition(offset: TestData.upperOffset)

            // Act
            let range = try #require(PinTextRange(from: from, to: to))

            // Assert
            #expect(range.length == TestData.upperOffset - TestData.lowerOffset)
        }

        @Test
        func testIsEmptyWhenMaxOffsetIsZeroShouldReturnTrue() {
            // Arrange
            let from = PinTextPosition(offset: TestData.lowerOffset)

            // Act
            let range = PinTextRange(from: from, maxOffset: TestData.zeroMaxOffset, in: TestData.baseString)

            // Assert
            #expect(range.isEmpty)
        }

        @Test
        func testIsEmptyWhenRangeSpansPositionsShouldReturnFalse() throws {
            // Arrange
            let range = try #require(
                PinTextRange(
                    from: PinTextPosition(offset: TestData.lowerOffset),
                    to: PinTextPosition(offset: TestData.upperOffset)
                )
            )

            // Act
            let isEmpty = range.isEmpty

            // Assert
            #expect(isEmpty == false)
        }

        @Test
        func testDescriptionWhenRangeSpansPositionsShouldMatchFormat() throws {
            // Arrange
            let range = try #require(
                PinTextRange(
                    from: PinTextPosition(offset: TestData.lowerOffset),
                    to: PinTextPosition(offset: TestData.upperOffset)
                )
            )

            // Act
            let description = range.description

            // Assert
            #expect(description == "[\(TestData.lowerOffset) ..< \(TestData.upperOffset)]")
        }

        @Test
        func testFullRangeWhenRangeSpansPositionsShouldMapToSubstring() throws {
            // Arrange
            let base = TestData.baseString
            let range = try #require(
                PinTextRange(
                    from: PinTextPosition(offset: TestData.lowerOffset),
                    to: PinTextPosition(offset: TestData.upperOffset)
                )
            )

            // Act
            let stringRange = range.fullRange(in: base)

            // Assert
            let expectedStart = base.index(base.startIndex, offsetBy: TestData.lowerOffset)
            let expectedEnd = base.index(base.startIndex, offsetBy: TestData.upperOffset)
            #expect(stringRange == expectedStart..<expectedEnd)
        }
    }
}

private enum TestData {
    static let baseString = "123456"
    static let lowerOffset = 1
    static let upperOffset = 4
    static let smallMaxOffset = 2
    static let hugeMaxOffset = 100
    static let negativeMaxOffset = -2
    static let hugeNegativeMaxOffset = -100
    static let zeroMaxOffset = 0
}
