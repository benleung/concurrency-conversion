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
        case currencyItem(CurrencyListItemView.Model)
    }
    
    enum DisplayMode {
        case currencyList
        case empty
        case error
    }
}
