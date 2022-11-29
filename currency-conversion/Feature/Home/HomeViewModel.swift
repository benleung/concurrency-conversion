//
//  HomeViewModel.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/24.
//

import Combine
import UIKit
import OrderedCollections

/// Event Sources (View's lifecycle, UI Events) that might trigger an update on UI
/// Input from ViewController to ViewModel
struct HomeViewModelInput {
    var didUpdateAmount = PassthroughSubject<Double?, Never>()
    var didTapCurrencyDropDownView = PassthroughSubject<Void, Never>()
    var didSelectedCurrency = PassthroughSubject<String, Never>()
    var viewWillAppear = PassthroughSubject<Void, Never>()
}

/// Data for UI's updates
/// Output from ViewModel to ViewController
protocol HomeViewModelOutput {
    var openCurrencySelectModal: AnyPublisher<(list: [CurrencySelectView.Item], selected: String), Never> { get }
    var selectedCurrencyUnit: AnyPublisher<String, Never> { get }
    var displayMode: AnyPublisher<HomeModel.DisplayMode, Never> { get }
    var snapshot: AnyPublisher<HomeModel.Snapshot, Never> { get }
}

/// ViewModel of Home
/// Contains the business logic to generate data for Home's UI.
/// Independent of the actual ui operation required to update the view
final class HomeViewModel: HomeViewModelOutput {
    private let input: HomeViewModelInput
    private var cancellables = Set<AnyCancellable>()

    // MARK: Output
    lazy var openCurrencySelectModal = {
        input.didTapCurrencyDropDownView
            .map { Void -> (list: [CurrencySelectView.Item], selected: String) in
                var items: [CurrencySelectView.Item] = []
                
                let currencyNames = AppUserDefaults.shared.currencyNames
                
                for symbol in self.currencies.value.keys {
                    if let currency = self.currencies.value[symbol] {
                        items.append(CurrencySelectView.Item(
                            currencyAlias: currency.symbol,
                            currencyNameWithAlias: currency.fullname
                        ))
                    }
                }
                return (list: items, selected: self._selectedCurrencyUnit.value)
            }
            .eraseToAnyPublisher()
    }()

    lazy var selectedCurrencyUnit: AnyPublisher<String, Never> = {
        _selectedCurrencyUnit.eraseToAnyPublisher()
    }()
    private var _selectedCurrencyUnit = CurrentValueSubject<String, Never>("USD")

    lazy var displayMode: AnyPublisher<HomeModel.DisplayMode, Never> = {
        Publishers.CombineLatest3(
            input.viewWillAppear,
            Publishers.Merge(Just(nil), input.didUpdateAmount),
            _snapshot.map(\.numberOfItems)
        ).map { _, didUpdateAmount, numberOfItems in
            if didUpdateAmount == nil {
                return .empty
            } else if numberOfItems != 0 {
                return .currencyList
            } else {
                return .error
            }
        }.eraseToAnyPublisher()
    }()
    
    lazy var snapshot: AnyPublisher<HomeModel.Snapshot, Never> = {
        return _snapshot.eraseToAnyPublisher()
    }()
    private var _snapshot = CurrentValueSubject<HomeModel.Snapshot, Never>(HomeModel.Snapshot())

    // MARK: private properties
    private var exchangeRates = CurrentValueSubject<[String: Double]?, Never>(nil)
    private var currencyNames = CurrentValueSubject<[String: String]?, Never>(nil)
    private var currencies = CurrentValueSubject<OrderedDictionary<String, GetCurrenciesUseCaseIO.Output.Currency>, Never>([:])
    
    init(input: HomeViewModelInput, getCurrenciesUseCase: GetCurrenciesUseCase = GetCurrenciesUseCaseImp()) {
        self.input = input
        
        // snapshot
        Publishers.CombineLatest3(
            currencies,
            selectedCurrencyUnit,
            input.didUpdateAmount.compactMap { $0 }
        )
            .sink { [weak self] currencies, selectedCurrencyUnit, amount in
                guard let self = self,
                      let selectedCurrencyRate = currencies[selectedCurrencyUnit]?.rate else {
                    return
                }

                var snapshot = HomeModel.Snapshot()
                var items: [CurrencyListItemView.Model] = []
                
                for currency in currencies.values {
                    let calculatedAmount = self.getCurrencyAmount(fromRate: selectedCurrencyRate, toRate: currency.rate, fromAmount: amount)
                    items.append(CurrencyListItemView.Model(
                        currencyAlias: currency.symbol,
                        currencyName: currency.name,
                        amount: calculatedAmount
                    ))
                }

                snapshot.appendSections([.currencyList])
                snapshot.appendItems(items.map { HomeModel.Item.currencyItem($0) })
                self._snapshot.send(snapshot)
            }
            .store(in: &cancellables)

        // side effects
        Publishers.Merge(
            input.viewWillAppear,
            input.didUpdateAmount.map { _ in () }
        ).sink {
            Task {
                let getCurrenciesUseCaseOutput = try await getCurrenciesUseCase.execute()
                self.currencies.send(getCurrenciesUseCaseOutput.currencies)
            }
        }
        .store(in: &cancellables)
        
        // selectedCurrencyUnit
        input.didSelectedCurrency.sink {
            self._selectedCurrencyUnit.send($0)
        }
        .store(in: &cancellables)
    }

    private func getCurrencyAmount(
        fromRate: Double,
        toRate: Double,
        fromAmount: Double
    ) -> String {
        let calculatedAmount = (fromAmount / fromRate) * toRate
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: calculatedAmount as NSNumber) ?? "-"
    }
}

private extension GetCurrenciesUseCaseIO.Output.Currency {
    var fullname: String {
        "\(symbol) (\(name))"
    }
}
