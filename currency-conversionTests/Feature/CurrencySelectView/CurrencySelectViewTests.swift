//
//  CurrencySelectViewTests.swift
//  currency-conversionTests
//
//  Created by Ben Leung on 2022/11/27.
//

import XCTest
@testable import currency_conversion

final class CurrencySelectViewTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_filterWithSearchText() throws {
        // Arrange
        let models = [
            CurrencySelectView.Model(currencyAlias: "USD", currencyNameWithAlias: "USD (United States Dollar)"),
            CurrencySelectView.Model(currencyAlias: "HKD", currencyNameWithAlias: "HKD (Hong Kong Dollar)"),
            CurrencySelectView.Model(currencyAlias: "JPY", currencyNameWithAlias: "JPY (Japanese Yen)")
        ]
        
        XCTContext.runActivity(named: "filter with Dollar") { _ in
            // Arrange
            let searchText = "Dollar"
            
            // Act
            let actual = models.filter {
                CurrencySelectView.filterWithSearchText(searchText: searchText, itemText: $0.currencyNameWithAlias)
            }
            
            // Assert
            let expected = [
                CurrencySelectView.Model(currencyAlias: "USD", currencyNameWithAlias: "USD (United States Dollar)"),
                CurrencySelectView.Model(currencyAlias: "HKD", currencyNameWithAlias: "HKD (Hong Kong Dollar)")
            ]
            XCTAssertEqual(actual, expected, "JPY is filtered out because it doesn't contain Dollar")
        }

        XCTContext.runActivity(named: "filter with empty string") { _ in
            // Arrange
            let searchText = ""
            
            // Act
            let actual = models.filter {
                CurrencySelectView.filterWithSearchText(searchText: searchText, itemText: $0.currencyNameWithAlias)
            }
            
            // Assert
            let expected = [
                CurrencySelectView.Model(currencyAlias: "USD", currencyNameWithAlias: "USD (United States Dollar)"),
                CurrencySelectView.Model(currencyAlias: "HKD", currencyNameWithAlias: "HKD (Hong Kong Dollar)"),
                CurrencySelectView.Model(currencyAlias: "JPY", currencyNameWithAlias: "JPY (Japanese Yen)")
            ]
            XCTAssertEqual(actual, expected, "no currencies are filltered when searchText is empty")
        }
    }
}
