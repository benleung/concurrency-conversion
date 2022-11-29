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
    private let timeProvider: TimeProviderProtocol
    private let getCurrencyListAPI: GetCurrencyListAPI
    private let getLatestExchangeRateAPI: GetLatestExchangeRateAPI
    
    init(
        timeProvider: TimeProviderProtocol = TimeProvider(),
        getCurrencyListAPI: GetCurrencyListAPI = GetCurrencyListAPI(),
        getLatestExchangeRateAPI: GetLatestExchangeRateAPI = GetLatestExchangeRateAPI()
    ) {
        self.timeProvider = timeProvider
        self.getCurrencyListAPI = getCurrencyListAPI
        self.getLatestExchangeRateAPI = getLatestExchangeRateAPI
    }
    
    func execute() async -> GetCurrenciesUseCaseIO.Output {
        // note: fetch currencyNames and exchangeRates asynchronously in parallel for better performance
        async let asyncCurrencyNames: [String: String] = {
            let secondsSinceLastCached = timeProvider.now().timeIntervalSinceReferenceDate - (AppUserDefaults.shared.currencyNamesLastUpdated ?? Date.distantPast).timeIntervalSinceReferenceDate
            if secondsSinceLastCached >= cacheExpireSeconds,
               // cache expires and need refresh
                let getCurrencyListAPIOutput = try? await getCurrencyListAPI.execute() {
                // note: if api fetching failed, AppUserDefaults.shared.currencyNames would be used, otherwise update the cache
                AppUserDefaults.shared.currencyNames = getCurrencyListAPIOutput
                AppUserDefaults.shared.currencyNamesLastUpdated = timeProvider.now()
            }
            return AppUserDefaults.shared.currencyNames
        }()

        async let asyncExchangeRates: [String : Double] = {
            let secondsSinceLastCached = timeProvider.now().timeIntervalSinceReferenceDate - (AppUserDefaults.shared.exchangeRatesLastUpdated ?? Date.distantPast).timeIntervalSinceReferenceDate
            if secondsSinceLastCached >= cacheExpireSeconds,
               // cache expires and need refresh
                let getLatestExchangeRateAPIOutput = try? await getLatestExchangeRateAPI.execute() {
                // note: if api fetching failed, AppUserDefaults.shared.exchangeRates would be used, otherwise update the cache
                AppUserDefaults.shared.exchangeRates = getLatestExchangeRateAPIOutput.rates
                AppUserDefaults.shared.exchangeRatesLastUpdated = timeProvider.now()
            }
            return AppUserDefaults.shared.exchangeRates
        }()
        
        let (currencyNames, exchangeRates) = await (asyncCurrencyNames, asyncExchangeRates)
        
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
