//
//  PinTextPositionTests.swift
//  NerdzPinView
//
//  Created by Roman Kovalchuk on 16.09.2026.
//

import Testing
@testable import NerdzPinView

@MainActor
@Suite("Pin Text Position")
struct PinTextPositionTests {

    @Test
    func testInitWhenGivenOffsetShouldStoreIt() {
        // Arrange
        let offset = TestData.offset

        // Act
        let position = PinTextPosition(offset: offset)

        // Assert
        #expect(position.offset == offset)
    }

    @Test
    func testDescriptionWhenGivenOffsetShouldMatchOffsetString() {
        // Arrange
        let offset = TestData.offset

        // Act
        let position = PinTextPosition(offset: offset)

        // Assert
        #expect(position.description == String(offset))
    }
}

private enum TestData {
    static let offset = 3
}
