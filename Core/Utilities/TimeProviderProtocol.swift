//
//  TimeProvider.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/28.
//

import Foundation

public protocol TimeProviderProtocol {
    func now() -> Date
}

public struct TimeProvider: TimeProviderProtocol {
    public func now() -> Date { Date() }
    
    public init() {}
}
