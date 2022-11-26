//
//  AppUserDefaults.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import Foundation

public class AppUserDefaults {
    enum UserDefaultsKey: String, CaseIterable {
        case exchangeRates
        case currencyNames

        var initValue: Any? {
            switch self {
            case .exchangeRates:
                return [String:Double]()
            case .currencyNames:
                return [String:String]()
            }
        }
    }

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        self.userDefaults.register(
            defaults: UserDefaultsKey.allCases.reduce([String: Any]()) { dict, userDefaultsKey in
                var dictionary = dict
                dictionary[userDefaultsKey.rawValue] = userDefaultsKey.initValue
                return dictionary
            }
        )
    }

    private let userDefaults: UserDefaults

    public static var shared = AppUserDefaults()

    public var exchangeRates: [String:Double] {
        get {
            return userDefaults.object(forKey: UserDefaultsKey.exchangeRates.rawValue) as? [String:Double] ?? [:]
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKey.exchangeRates.rawValue)
        }
    }

    public var currencyNames: [String:String] {
        get {
            return userDefaults.object(forKey: UserDefaultsKey.currencyNames.rawValue) as? [String:String] ?? [:]
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKey.currencyNames.rawValue)
        }
    }
}
