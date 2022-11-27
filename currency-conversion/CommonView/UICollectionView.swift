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

    // FIXME: this is not used?
    func register(_ viewClass: UICollectionReusableView.Type, kind: String) {
        register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: viewClass))
    }

//    internal func reloadData(completion: @escaping (() -> Void)) {
//        reloadData()
//        performBatchUpdates(nil) { _ in
//            completion()
//        }
//    }
//
//    internal func reloadDataWait(completion: @escaping (() -> Void)) {
//        UIView.animate(withDuration: 0) {
//            self.reloadData()
//        } completion: { _ in
//            completion()
//        }
//    }
//
//    // reloadDataWait(completion:)だと正しい表示ができないケースがあったので、0.5秒遅延実行してcompletionを実行するメソッドを生成
//    // 1秒だと長すぎ0.3秒だと短すぎるので0.5秒に設定
//    internal func reloadDataAsyncAfter(completion: @escaping (() -> Void)) {
//        reloadData()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            completion()
//        }
//    }
}
