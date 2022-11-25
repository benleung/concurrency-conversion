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
        case currencyBlockGrid
    }
    enum Item: Hashable {
        case currencyBlock(ConversionResultCell.Model)
    }
}
