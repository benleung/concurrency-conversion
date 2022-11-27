//
//  TimeProvider.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/28.
//

import Foundation

protocol TimeProvider {
    func now() -> Date
}

struct TimeProviderImp: TimeProvider {
    func now() -> Date { Date() }
}
