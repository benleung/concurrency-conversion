//
//  APIRequestProtocol.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import Foundation

protocol OpenExchangeRatesApiProtocol {
    var path: String { get }
}

extension OpenExchangeRatesApiProtocol {
    private var baseUrl: String { "https://openexchangerates.org/api/" }
    private var queryParamKeyAppId: String { "app_id" }
    private var appId: String { "5d33f5e06cf24b2888783753f6868afb" }
    
    func request() -> URL {
        guard let url = URL(string: "\(baseUrl)\(path)?\(queryParamKeyAppId)=\(appId)") else {
            fatalError("Incorrect path for api request. path: \(path)")
        }
        return url
    }

    func perform<T: Decodable>(decode decodable: T.Type) async throws -> T {

        let (data, _) = try await URLSession.shared.data(from: request())
        guard let result = try? JSONDecoder().decode(T.self, from:data) else {
            throw APIError.unexpected
        }
        return result
    }

    func perform() async throws -> [String: String] {

        let (data, _) = try await URLSession.shared.data(from: request())
        guard let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else {
            throw APIError.unexpected
        }
        return result
    }
}
