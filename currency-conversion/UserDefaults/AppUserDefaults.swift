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
        case exchangeRatesLastUpdated
        case currencyNames
        case currencyNamesLastUpdated

        var initValue: Any? {
            switch self {
            case .exchangeRates:
                return [String:Double]()
            case .exchangeRatesLastUpdated:
                return nil
            case .currencyNames:
                return [String:String]()
            case .currencyNamesLastUpdated:
                return nil
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

    public var exchangeRatesLastUpdated: Date? {
        get {
            let timeIntervalSince1970 = userDefaults.double(forKey: UserDefaultsKey.exchangeRatesLastUpdated.rawValue) as Double?
            return timeIntervalSince1970.map { Date(timeIntervalSince1970: $0) }
        }
        set {
            userDefaults.set(newValue?.timeIntervalSince1970, forKey: UserDefaultsKey.exchangeRatesLastUpdated.rawValue)
        }
    }

    public var currencyNamesLastUpdated: Date? {
        get {
            let timeIntervalSince1970 = userDefaults.double(forKey: UserDefaultsKey.currencyNamesLastUpdated.rawValue) as Double?
            return timeIntervalSince1970.map { Date(timeIntervalSince1970: $0) }
        }
        set {
            userDefaults.set(newValue?.timeIntervalSince1970, forKey: UserDefaultsKey.currencyNamesLastUpdated.rawValue)
        }
    }
}
