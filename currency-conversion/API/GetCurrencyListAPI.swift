//
//  GetCurrencyListAPI.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import Foundation

class GetCurrencyListAPI : OpenExchangeRatesApiProtocol {
    var path: String = "currencies.json"
    
    func execute() async throws -> [String: String] {
        try await perform()
    }
}
