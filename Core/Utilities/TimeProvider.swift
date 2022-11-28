//
//  TimeProvider.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/28.
//

import Foundation

public protocol TimeProvider {
    func now() -> Date
}

public struct TimeProviderImp: TimeProvider {
    public func now() -> Date { Date() }
    
    public init() {}
}
