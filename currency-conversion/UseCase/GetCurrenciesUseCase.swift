//
//  GetCurrenciesUseCase.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import Foundation
import OrderedCollections

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
    func execute() async throws -> GetCurrenciesUseCaseIO.Output {

        let currencyNames: [String: String] = try await {
            if let lastUpdated = AppUserDefaults.shared.currencyNamesLastUpdated, lastUpdated.timeIntervalSinceNow >= -60*30 {
                // cache expires and need refresh
                AppUserDefaults.shared.currencyNamesLastUpdated = Date()
                AppUserDefaults.shared.currencyNames = try await GetCurrencyListAPI().perform()
            }
            return AppUserDefaults.shared.currencyNames
        }()

        let exchangeRates: [String : Double] = try await {
            if let lastUpdated = AppUserDefaults.shared.currencyNamesLastUpdated, lastUpdated.timeIntervalSinceNow >= -60*30 {
                // cache expires and need refresh
                AppUserDefaults.shared.exchangeRatesLastUpdated = Date()
                AppUserDefaults.shared.exchangeRates = try await GetLatestExchangeRateAPI().perform(decode: GetLatestExchangeRateResponse.self).rates
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
