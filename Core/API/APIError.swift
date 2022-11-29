//
//  APIError.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import Foundation

public enum APIError: Error {
    /// response code
    case badResponse(Int?)
    case custom(Error)
    case unexpected
}

