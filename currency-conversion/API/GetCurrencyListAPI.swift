//
//  GetCurrencyListAPI.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import Core

protocol GetCurrencyListAPIProtocol {
    func execute() async throws -> [String: String]
}

struct GetCurrencyListAPI: GetCurrencyListAPIProtocol, OpenExchangeRatesApiProtocol {
    var path: String = "currencies.json"
    
    func execute() async throws -> [String: String] {
        try await perform()
    }
}
