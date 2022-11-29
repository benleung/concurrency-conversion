//
//  CoreTests.swift
//  CoreTests
//
//  Created by Ben Leung on 2022/11/28.
//

import XCTest
@testable import Core

final class CoreTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // amount that is allowed to input
    func test_isValidDecimalString() throws {
        // Arrange
        let empty = ""
        let zero = "0"
        let onlyDigits = "1"
        let onlyDigits2 = "12"
        let onlyDot = "."
        let withDotNoFloatingDigits = "123."
        let withDotAndFloatingDigits = "123.1"
        let withDotAndFloatingDigits2 = "123.12"
        
        let multipleDots = "123.12.123"
        let alphabats = "123.12fuzz"
        
        let textField = NumberInputTextField()
        
        
        // Act & Assert
        XCTAssertTrue(textField.isValidDecimalString(text: empty))
        XCTAssertTrue(textField.isValidDecimalString(text: zero))
        XCTAssertTrue(textField.isValidDecimalString(text: onlyDigits))
        XCTAssertTrue(textField.isValidDecimalString(text: onlyDigits2))
        XCTAssertTrue(textField.isValidDecimalString(text: onlyDot))
        XCTAssertTrue(textField.isValidDecimalString(text: withDotNoFloatingDigits))
        XCTAssertTrue(textField.isValidDecimalString(text: withDotAndFloatingDigits))
        XCTAssertTrue(textField.isValidDecimalString(text: withDotAndFloatingDigits2))
        XCTAssertFalse(textField.isValidDecimalString(text: multipleDots))
        XCTAssertFalse(textField.isValidDecimalString(text: alphabats))
    }

}
