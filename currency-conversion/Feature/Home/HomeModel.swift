//
//  HomeModel.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/25.
//

import UIKit

public enum HomeModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    enum Section: Hashable {
        case currencyList
    }
    enum Item: Hashable {
        /// a currency block containing calcuated amount, current symbol and full name
        case currencyItem(CurrencyListItemView.Model)
    }
    
    enum DisplayMode {
        /// diplay a list of currency based on exchange rate
        case currencyList
        /// display a message to prompt user to input an amount
        case empty
        /// display a message to prompt user that an error has occurred so that a list of currency cannot be displayed correctly
        case error
    }
}
