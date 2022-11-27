//
//  GetLatestExchangeRateAPI.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import Foundation

struct GetLatestExchangeRateAPI: OpenExchangeRatesApiProtocol {
    var path: String = "latest.json"
}

struct GetLatestExchangeRateResponse: Decodable {
    var timestamp: Int
    var base: String
    var rates: [String: Double]
}
