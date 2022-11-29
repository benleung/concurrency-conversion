//
//  UICollectionView.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/25.
//

import UIKit

public extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind: String, for indexPath: IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: ofKind, withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
    }

    func register(_ cellClass: UICollectionViewCell.Type) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }
}
