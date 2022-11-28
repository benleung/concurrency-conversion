//
//  GetLatestExchangeRateAPI.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import Core

class GetLatestExchangeRateAPI: OpenExchangeRatesApiProtocol {
    var path: String = "latest.json"
    
    func execute() async throws -> GetLatestExchangeRateResponse {
        try await perform(decode: GetLatestExchangeRateResponse.self)
    }
}

struct GetLatestExchangeRateResponse: Decodable {
    var timestamp: Int
    var base: String
    var rates: [String: Double]
}
