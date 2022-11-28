//
//  HomeViewModelTests.swift
//  currency-conversionTests
//
//  Created by Ben Leung on 2022/11/26.
//

import XCTest
import OrderedCollections
@testable import currency_conversion

final class HomeViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: major scenarios
    func test_viewWillAppear() throws {
        // Arrange
        let input = HomeViewModelInput()
        let output: HomeViewModelOutput = HomeViewModel(input: input, getCurrenciesUseCase: GetCurrenciesUseCaseSuccessMock())
        let displayMode = TestableSubscriber<HomeModel.DisplayMode, Never>()
        output.displayMode.receive(subscriber: displayMode)
        
        // Act
        input.viewWillAppear.send()
        
        // Assert
        XCTAssertEqual(displayMode.value, .empty,
                                   "EmptyView is shown to prompt user to enter currency amount")
    }

    func test_didUpdateAmount() throws {
        // Arrange
        let input = HomeViewModelInput()
        let output: HomeViewModelOutput = HomeViewModel(input: input, getCurrenciesUseCase: GetCurrenciesUseCaseSuccessMock())
        let displayMode = TestableSubscriber<HomeModel.DisplayMode, Never>()
        output.displayMode.receive(subscriber: displayMode)
        
        // Act
        input.viewWillAppear.send()
        input.didUpdateAmount.send(10) // 10 USD (default unit is "USD")

        // Assert
        let waitAfterDidUpdateAmount = expectation(description: "Currency blocks updated asynchronously after inputing 10 USD")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(displayMode.value, .currencyList, "EmptyView is hidden after inputing currency amount")
            let snapshot = TestableSubscriber<HomeModel.Snapshot, Never>()
            output.snapshot.receive(subscriber: snapshot)
            
            let actual: [CurrencyListItemView.Model] = snapshot.value.itemIdentifiers.compactMap {
                if case let HomeModel.Item.currencyItem(model) = $0 {
                    return model
                }
                return nil
            }
            let expected = [
                CurrencyListItemView.Model(currencyAlias: "HKD", currencyName: "Hong Kong Dollar", amount: "78.17"), // 10 USD = 7.81686*10 HKD
                CurrencyListItemView.Model(currencyAlias: "JPY", currencyName: "Japanese Yen", amount: "1391.20"), // 10 USD = 139.12*10 JPY
                CurrencyListItemView.Model(currencyAlias: "USD", currencyName: "United States Dollar", amount: "10.00"), // 10 USD
                
            ]
            XCTAssertEqual(actual, expected)
            waitAfterDidUpdateAmount.fulfill()
        }
        wait(for: [waitAfterDidUpdateAmount], timeout: 5.0)
    }

    func test_didTapCurrencyDropDownView_afterViewAppeared() throws {
        // Arrange
        let input = HomeViewModelInput()
        let output: HomeViewModelOutput = HomeViewModel(input: input, getCurrenciesUseCase: GetCurrenciesUseCaseSuccessMock())
        let openCurrencySelectModal = TestableSubscriber<(list: [CurrencySelectView.Model], selected: String), Never>()
        output.openCurrencySelectModal.receive(subscriber: openCurrencySelectModal)
        
        // Act
        input.viewWillAppear.send()
        
        let waitAfterAppearing = expectation(description: "wait after appear")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            
            XCTContext.runActivity(named: "currencySelectButton is not tapped") { _ in
                // Act
                // Do nothing
                
                // Assert
                XCTAssertEqual(openCurrencySelectModal.successCallCount, 0,
                                           "CurrencySelectView is not opened")
            }
            
            XCTContext.runActivity(named: "currencySelectButton is tapped") { _ in
                typealias Item = CurrencySelectView.Model
                // Act
                input.didTapCurrencyDropDownView.send()

                // Assert
                let expectedList = [
                    Item(currencyAlias: "HKD", currencyNameWithAlias: "HKD (Hong Kong Dollar)"),
                    Item(currencyAlias: "JPY", currencyNameWithAlias: "JPY (Japanese Yen)"),
                    Item(currencyAlias: "USD", currencyNameWithAlias: "USD (United States Dollar)")
                ]
                XCTAssertEqual(openCurrencySelectModal.successCallCount, 1,
                                           "CurrencySelectView is opened")
                XCTAssertEqual(openCurrencySelectModal.value.list, expectedList,
                                           "CurrencySelectView is opened")
                // note: USD is the default selected currency
                XCTAssertEqual(openCurrencySelectModal.value.selected, "USD",
                                           "CurrencySelectView is opened with USD selected")
            }
            waitAfterAppearing.fulfill()
        }
        wait(for: [waitAfterAppearing], timeout: 5.0)
    }

    func test_didTapCurrencyDropDownView_afterSelectedAnotherCurrency() throws {
        // Arrange
        let input = HomeViewModelInput()
        let output: HomeViewModelOutput = HomeViewModel(input: input, getCurrenciesUseCase: GetCurrenciesUseCaseSuccessMock())
        let openCurrencySelectModal = TestableSubscriber<(list: [CurrencySelectView.Model], selected: String), Never>()
        output.openCurrencySelectModal.receive(subscriber: openCurrencySelectModal)
        
        // Act
        input.viewWillAppear.send()
        input.didSelectedCurrency.send("HKD") // assume "HKD" has been selected on HomeView
        
        let waitAfterAppearing = expectation(description: "after selecting HKD")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            XCTContext.runActivity(named: "currencySelectButton is tapped") { _ in
                typealias Item = CurrencySelectView.Model
                // Act
                input.didTapCurrencyDropDownView.send()

                // Assert
                let expectedList = [
                    Item(currencyAlias: "HKD", currencyNameWithAlias: "HKD (Hong Kong Dollar)"),
                    Item(currencyAlias: "JPY", currencyNameWithAlias: "JPY (Japanese Yen)"),
                    Item(currencyAlias: "USD", currencyNameWithAlias: "USD (United States Dollar)")
                ]
                XCTAssertEqual(openCurrencySelectModal.successCallCount, 1,
                                           "CurrencySelectView is opened")
                XCTAssertEqual(openCurrencySelectModal.value.list, expectedList,
                                           "CurrencySelectView is opened")
                // note: here openCurrencySelectModal would display HKD as the selected currency
                XCTAssertEqual(openCurrencySelectModal.value.selected, "HKD",
                                           "CurrencySelectView is opened with USD selected")
            }
            waitAfterAppearing.fulfill()
        }
        wait(for: [waitAfterAppearing], timeout: 5.0)
    }

    func test_didUpdateSelectedAmount() throws {
        // Arrange
        let input = HomeViewModelInput()
        let output: HomeViewModelOutput = HomeViewModel(input: input, getCurrenciesUseCase: GetCurrenciesUseCaseSuccessMock())
        let displayMode = TestableSubscriber<HomeModel.DisplayMode, Never>()
        output.displayMode.receive(subscriber: displayMode)
        
        // Act
        input.viewWillAppear.send()
        input.didUpdateAmount.send(10) // 10 USD (default unit is "USD")
        input.didSelectedCurrency.send("HKD") // 10 HKD

        // Assert
        let waitAfterDidUpdateAmount = expectation(description: "Currency blocks updated asynchronously after inputing 10 HKD")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(displayMode.value, .currencyList, "currencyList is shown after inputing currency amount")
            let snapshot = TestableSubscriber<HomeModel.Snapshot, Never>()
            output.snapshot.receive(subscriber: snapshot)
            
            let actual: [CurrencyListItemView.Model] = snapshot.value.itemIdentifiers.compactMap {
                if case let HomeModel.Item.currencyItem(model) = $0 {
                    return model
                }
                return nil
            }
            let expected = [
                CurrencyListItemView.Model(currencyAlias: "HKD", currencyName: "Hong Kong Dollar", amount: "10.00"), // 10 HKD
                CurrencyListItemView.Model(currencyAlias: "JPY", currencyName: "Japanese Yen", amount: "177.97"), // 10 HKD = 10 / 7.81686 * 139.12 = 177.97 JPY
                CurrencyListItemView.Model(currencyAlias: "USD", currencyName: "United States Dollar", amount: "1.28"), // 10 HKD = 10 / 7.81686 = 1.28 USD
                
            ]
            XCTAssertEqual(actual, expected)
            waitAfterDidUpdateAmount.fulfill()
        }
        wait(for: [waitAfterDidUpdateAmount], timeout: 5.0)
    }
    
    // MARK: Edge Cases
    
    func test_didUpdateSelectedAmount_clearing_textfield() {
        // Arrange
        let input = HomeViewModelInput()
        let output: HomeViewModelOutput = HomeViewModel(input: input, getCurrenciesUseCase: GetCurrenciesUseCaseSuccessMock()) // note: GetCurrenciesUseCaseErrorMock to simulate error occurred while fetching data
        let displayMode = TestableSubscriber<HomeModel.DisplayMode, Never>()
        output.displayMode.receive(subscriber: displayMode)
        
        // Act
        input.viewWillAppear.send()
        input.didUpdateAmount.send(10) // 10 USD (default unit is "USD")
        input.didUpdateAmount.send(nil) // backspace to clear up the field

        // Assert
        let waitAfterDidUpdateAmount = expectation(description: "Error view displayed asynchronously after inputing 10 HKD but failed to fetch data")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(displayMode.value, .empty, "currencyList is shown after inputing currency amount")
            waitAfterDidUpdateAmount.fulfill()
        }
        wait(for: [waitAfterDidUpdateAmount], timeout: 5.0)
    }
    
    func test_didUpdateSelectedAmount_error_on_getCurrenciesUseCase() throws {
        // Arrange
        let input = HomeViewModelInput()
        let output: HomeViewModelOutput = HomeViewModel(input: input, getCurrenciesUseCase: GetCurrenciesUseCaseErrorMock()) // note: GetCurrenciesUseCaseErrorMock to simulate error occurred while fetching data
        let displayMode = TestableSubscriber<HomeModel.DisplayMode, Never>()
        output.displayMode.receive(subscriber: displayMode)
        
        // Act
        input.viewWillAppear.send()
        input.didUpdateAmount.send(10) // 10 USD (default unit is "USD")

        // Assert
        let waitAfterDidUpdateAmount = expectation(description: "Error view displayed asynchronously after inputing 10 HKD but failed to fetch data")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(displayMode.value, .error, "currencyList is shown after inputing currency amount")
            waitAfterDidUpdateAmount.fulfill()
        }
        wait(for: [waitAfterDidUpdateAmount], timeout: 5.0)
    }
    
    
    func test_didTapCurrencyDropDownView_error_on_getCurrenciesUseCase() throws {
        // Arrange
        let input = HomeViewModelInput()
        let output: HomeViewModelOutput = HomeViewModel(input: input, getCurrenciesUseCase: GetCurrenciesUseCaseErrorMock())
        let openCurrencySelectModal = TestableSubscriber<(list: [CurrencySelectView.Model], selected: String), Never>()
        output.openCurrencySelectModal.receive(subscriber: openCurrencySelectModal)
        
        // Act
        input.viewWillAppear.send()
        input.didSelectedCurrency.send("HKD") // assume "HKD" has been selected on HomeView
        
        let waitAfterAppearing = expectation(description: "after selecting HKD")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            XCTContext.runActivity(named: "currencySelectButton is tapped") { _ in
                typealias Item = CurrencySelectView.Model
                // Act
                input.didTapCurrencyDropDownView.send()

                // Assert
                let expectedList: [Item] = []
                XCTAssertEqual(openCurrencySelectModal.successCallCount, 1,
                                           "CurrencySelectView is opened")
                XCTAssertEqual(openCurrencySelectModal.value.list, expectedList,
                                           "an empty list is shown")
            }
            waitAfterAppearing.fulfill()
        }
        wait(for: [waitAfterAppearing], timeout: 5.0)
    }
}

private struct GetCurrenciesUseCaseSuccessMock: GetCurrenciesUseCase {
    typealias Currency = GetCurrenciesUseCaseIO.Output.Currency
    
    func execute() async throws -> GetCurrenciesUseCaseIO.Output {
        var currencies: OrderedDictionary<String, Currency> = [
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
        return GetCurrenciesUseCaseIO.Output(
            currencies: currencies
        )
    }
}

private struct GetCurrenciesUseCaseErrorMock: GetCurrenciesUseCase {
    typealias Currency = GetCurrenciesUseCaseIO.Output.Currency
    
    func execute() async throws -> GetCurrenciesUseCaseIO.Output {
        throw APIError.unexpected
    }
}
