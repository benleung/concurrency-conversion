//
//  GetCurrenciesUseCaseTests.swift
//  currency-conversionTests
//
//  Created by Ben Leung on 2022/11/28.
//

import XCTest
import OrderedCollections
import Core
@testable import currency_conversion

final class GetCurrenciesUseCaseTests: XCTestCase {
    typealias Currency = GetCurrenciesUseCaseIO.Output.Currency

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_execute_first_time() {
        // Arrange
        let mockCurrentDate = Date(timeIntervalSince1970: 10000)
        let mockTimeProvider = MockTimeProvider(currentDate: mockCurrentDate)
        let useCase = GetCurrenciesUseCaseImp(
            timeProvider: mockTimeProvider,
            getCurrencyListAPI: MockGetCurrencyListAPI(),
            getLatestExchangeRateAPI: MockGetLatestExchangeRateAPI()
        )
        
        AppUserDefaults.shared.currencyNames = [:]
        AppUserDefaults.shared.exchangeRates = [:]
        AppUserDefaults.shared.currencyNamesLastUpdated = nil
        AppUserDefaults.shared.exchangeRatesLastUpdated = nil

        let waitForUseCaseExecute = expectation(description: "Wait for use Case Execution")
        Task {
            // Act
            let currencies = try! await useCase.execute().currencies
            
            // Assert
            let expectedCurrencies: OrderedDictionary<String, Currency> = [
                "HKD": Currency(
                    rate: 7.81686,
                    symbol: "HKD",
                    name: "Hong Kong Dollar"
                ),
                "JPY": Currency(
                    rate: 139.12,
                    symbol: "JPY",
                    name: "Japanese Yen"
                ),
                "USD": Currency(
                    rate: 1,
                    symbol: "USD",
                    name: "United States Dollar"
                )
            ]
            
            XCTAssertTrue(currencies.keys == expectedCurrencies.keys && currencies.values == expectedCurrencies.values,
                                       "currencies is fetched corrected from api")
            
            for symbol in expectedCurrencies.keys {
                XCTAssertEqual(AppUserDefaults.shared.exchangeRates[symbol] ?? 0, expectedCurrencies[symbol]?.rate ?? 0, accuracy: 0.000000001,
                                           "exchangeRates is cached")
                XCTAssertEqual(AppUserDefaults.shared.currencyNames[symbol], expectedCurrencies[symbol]?.name,
                                           "currencyNames is cached")
            }
            
            XCTAssertEqual(AppUserDefaults.shared.currencyNamesLastUpdated, mockCurrentDate,
                                       "currencyNamesLastUpdated is cached")
            XCTAssertEqual(AppUserDefaults.shared.exchangeRatesLastUpdated, mockCurrentDate,
                                       "exchangeRatesLastUpdated is cached")
            waitForUseCaseExecute.fulfill()
        }
        wait(for: [waitForUseCaseExecute], timeout: 5.0)
    }

    func test_execute_again_with_20mintues() {
        // Arrange
        let lastCachedDate = Date(timeIntervalSince1970: 10000)
        let mockCurrentDate = Date(timeIntervalSince1970: 10000 + 60*20) // 20 minutes later
        let mockTimeProvider = MockTimeProvider(currentDate: mockCurrentDate)
        let useCase = GetCurrenciesUseCaseImp(
            timeProvider: mockTimeProvider,
            getCurrencyListAPI: MockGetCurrencyListAPI(),
            getLatestExchangeRateAPI: MockGetLatestExchangeRateAPI()
        )
        
        AppUserDefaults.shared.currencyNames = [
            "HKD": "Hong Kong Dollar"
        ]
        AppUserDefaults.shared.exchangeRates = [
            "HKD": 7.81686
        ]
        AppUserDefaults.shared.currencyNamesLastUpdated = lastCachedDate
        AppUserDefaults.shared.exchangeRatesLastUpdated = lastCachedDate

        let waitForUseCaseExecute = expectation(description: "Wait for use Case Execution")
        Task {
            // Act
            let currencies = try! await useCase.execute().currencies
            
            // Assert
            let expectedCurrencies: OrderedDictionary<String, Currency> = [
                "HKD": Currency(
                    rate: 7.81686,
                    symbol: "HKD",
                    name: "Hong Kong Dollar"
                )
            ]
            
            XCTAssertTrue(currencies.keys == expectedCurrencies.keys && currencies.values == expectedCurrencies.values,
                                       "currencies is fetched from cache instead of api")
            
            for symbol in expectedCurrencies.keys {
                XCTAssertEqual(AppUserDefaults.shared.exchangeRates[symbol] ?? 0, expectedCurrencies[symbol]?.rate ?? 0, accuracy: 0.000000001,
                                           "exchangeRates is unchanged")
                XCTAssertEqual(AppUserDefaults.shared.currencyNames[symbol], expectedCurrencies[symbol]?.name,
                                           "currencyNames is unchanged")
            }
            
            XCTAssertEqual(AppUserDefaults.shared.currencyNamesLastUpdated, lastCachedDate,
                                       "cached currencyNamesLastUpdated is unchanged")
            XCTAssertEqual(AppUserDefaults.shared.exchangeRatesLastUpdated, lastCachedDate,
                                       "cached exchangeRatesLastUpdated is unchanged")
            waitForUseCaseExecute.fulfill()
        }
        wait(for: [waitForUseCaseExecute], timeout: 5.0)
    }

    func test_execute_again_with_40mintues() {
        // Arrange
        let lastCachedDate = Date(timeIntervalSince1970: 10000)
        let mockCurrentDate = Date(timeIntervalSince1970: 10000 + 60*40) // 40 minutes later
        let mockTimeProvider = MockTimeProvider(currentDate: mockCurrentDate)
        let useCase = GetCurrenciesUseCaseImp(
            timeProvider: mockTimeProvider,
            getCurrencyListAPI: MockGetCurrencyListAPI(),
            getLatestExchangeRateAPI: MockGetLatestExchangeRateAPI()
        )
        
        AppUserDefaults.shared.currencyNames = [
            "HKD": "Hong Kong Dollar"
        ]
        AppUserDefaults.shared.exchangeRates = [
            "HKD": 7.81686
        ]
        AppUserDefaults.shared.currencyNamesLastUpdated = lastCachedDate
        AppUserDefaults.shared.exchangeRatesLastUpdated = lastCachedDate

        let waitForUseCaseExecute = expectation(description: "Wait for use Case Execution")
        Task {
            // Act
            let currencies = try! await useCase.execute().currencies
            
            // Assert
            let expectedCurrencies: OrderedDictionary<String, Currency> = [
                "HKD": Currency(
                    rate: 7.81686,
                    symbol: "HKD",
                    name: "Hong Kong Dollar"
                ),
                "JPY": Currency(
                    rate: 139.12,
                    symbol: "JPY",
                    name: "Japanese Yen"
                ),
                "USD": Currency(
                    rate: 1,
                    symbol: "USD",
                    name: "United States Dollar"
                )
            ]
            
            XCTAssertTrue(currencies.keys == expectedCurrencies.keys && currencies.values == expectedCurrencies.values,
                                       "currencies is fetched from cache instead of api")
            
            for symbol in expectedCurrencies.keys {
                XCTAssertEqual(AppUserDefaults.shared.exchangeRates[symbol] ?? 0, expectedCurrencies[symbol]?.rate ?? 0, accuracy: 0.000000001,
                                           "exchangeRates is unchanged")
                XCTAssertEqual(AppUserDefaults.shared.currencyNames[symbol], expectedCurrencies[symbol]?.name,
                                           "currencyNames is unchanged")
            }
            
            XCTAssertEqual(AppUserDefaults.shared.currencyNamesLastUpdated, mockCurrentDate,
                                       "cached currencyNamesLastUpdated is updated")
            XCTAssertEqual(AppUserDefaults.shared.exchangeRatesLastUpdated, mockCurrentDate,
                                       "cached exchangeRatesLastUpdated is updated")
            waitForUseCaseExecute.fulfill()
        }
        wait(for: [waitForUseCaseExecute], timeout: 5.0)
    }
    
    func test_execute_error() {
        // Arrange
        let mockCurrentDate = Date(timeIntervalSince1970: 10000)
        let mockTimeProvider = MockTimeProvider(currentDate: mockCurrentDate)
        let useCase = GetCurrenciesUseCaseImp(
            timeProvider: mockTimeProvider,
            getCurrencyListAPI: MockGetCurrencyListAPIError(),
            getLatestExchangeRateAPI: MockGetLatestExchangeRateAPIError()
        )
        
        AppUserDefaults.shared.currencyNames = [:]
        AppUserDefaults.shared.exchangeRates = [:]
        AppUserDefaults.shared.currencyNamesLastUpdated = nil
        AppUserDefaults.shared.exchangeRatesLastUpdated = nil

        let waitForUseCaseExecute = expectation(description: "Wait for use Case Execution")
        Task {
            // Act & Assert
            do {
                _ = try await useCase.execute().currencies
                XCTAssert(false, "Should throw when there is api error")
            } catch {
                // success
            }
            waitForUseCaseExecute.fulfill()
        }
        wait(for: [waitForUseCaseExecute], timeout: 5.0)
    }
}

private class MockTimeProvider: TimeProviderProtocol {
    var currentDate: Date
    
    init(currentDate: Date = Date()) {
        self.currentDate = currentDate
    }
    
    func configure(currentDate: Date) {
        self.currentDate = currentDate
    }
    
    func now() -> Date {
        currentDate
    }
}

private class MockGetCurrencyListAPI: GetCurrencyListAPI {
    
    override func execute() async throws -> [String: String] {
        return [
            "HKD": "Hong Kong Dollar",
            "JPY": "Japanese Yen",
            "USD": "United States Dollar"
        ]
    }
}

private class MockGetLatestExchangeRateAPI: GetLatestExchangeRateAPI {
    override func execute() async throws -> GetLatestExchangeRateResponse {

        let result = GetLatestExchangeRateResponse(timestamp: 0, base: "USD", rates: [
            "HKD": 7.81686,
            "JPY": 139.12,
            "USD": 1
        ])
        
        return result
    }
}

private class MockGetCurrencyListAPIError: GetCurrencyListAPI {
    
    override func execute() async throws -> [String: String] {
        throw APIError.unexpected
    }
}

private class MockGetLatestExchangeRateAPIError: GetLatestExchangeRateAPI {
    override func execute() async throws -> GetLatestExchangeRateResponse {
        throw APIError.unexpected
    }
}
