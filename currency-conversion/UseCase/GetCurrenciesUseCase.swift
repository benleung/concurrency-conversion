//
//  GetCurrenciesUseCase.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import Foundation
import OrderedCollections
import Core

protocol GetCurrenciesUseCase {
    func execute() async throws -> GetCurrenciesUseCaseIO.Output
}

struct GetCurrenciesUseCaseIO : Codable {
    struct Output {
        /// symbol -> Currency
        var currencies: OrderedDictionary<String, Currency>
        
        struct Currency: Equatable {
            var rate: Double
            let symbol: String
            let name: String
        }
    }
}

struct GetCurrenciesUseCaseImp: GetCurrenciesUseCase {
    private let cacheExpireSeconds: TimeInterval = 60*30 // 30 mintues
    private let timeProvider: TimeProvider
    private let getCurrencyListAPI: GetCurrencyListAPI
    private let getLatestExchangeRateAPI: GetLatestExchangeRateAPI
    
    init(
        timeProvider: TimeProvider = TimeProviderImp(),
        getCurrencyListAPI: GetCurrencyListAPI = GetCurrencyListAPI(),
        getLatestExchangeRateAPI: GetLatestExchangeRateAPI = GetLatestExchangeRateAPI()
    ) {
        self.timeProvider = timeProvider
        self.getCurrencyListAPI = getCurrencyListAPI
        self.getLatestExchangeRateAPI = getLatestExchangeRateAPI
    }
    
    func execute() async throws -> GetCurrenciesUseCaseIO.Output {
        // FIXME: should use async let
        let currencyNames: [String: String] = try await {
            let secondsSinceLastCached = timeProvider.now().timeIntervalSinceReferenceDate - (AppUserDefaults.shared.currencyNamesLastUpdated ?? Date.distantPast).timeIntervalSinceReferenceDate
            if secondsSinceLastCached >= cacheExpireSeconds {
                // cache expires and need refresh
                AppUserDefaults.shared.currencyNames = try await getCurrencyListAPI.execute()
                AppUserDefaults.shared.currencyNamesLastUpdated = timeProvider.now()
            }
            return AppUserDefaults.shared.currencyNames
        }()

        let exchangeRates: [String : Double] = try await {
            let secondsSinceLastCached = timeProvider.now().timeIntervalSinceReferenceDate - (AppUserDefaults.shared.exchangeRatesLastUpdated ?? Date.distantPast).timeIntervalSinceReferenceDate
            if secondsSinceLastCached >= cacheExpireSeconds {
                // cache expires and need refresh
                AppUserDefaults.shared.exchangeRates = try await getLatestExchangeRateAPI.execute().rates
                AppUserDefaults.shared.exchangeRatesLastUpdated = timeProvider.now()
            }
            return AppUserDefaults.shared.exchangeRates
        }()
        
        var currencies = OrderedDictionary<String, GetCurrenciesUseCaseIO.Output.Currency>()
        for symbol in exchangeRates.keys.sorted() {
            if let name = currencyNames[symbol],
               let exchangeRate = exchangeRates[symbol] {
                currencies[symbol] = GetCurrenciesUseCaseIO.Output.Currency(
                    rate: exchangeRate,
                    symbol: symbol,
                    name: name
                )
            }
        }
        return GetCurrenciesUseCaseIO.Output(
            currencies: currencies
        )
    }
}
