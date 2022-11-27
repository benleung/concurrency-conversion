//
//  GetCurrencyListAPI.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import Foundation

struct GetCurrencyListAPI : OpenExchangeRatesApiProtocol {
    var path: String = "currencies.json"
}
