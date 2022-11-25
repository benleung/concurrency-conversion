//
//  FixSafeAreaInsetsHostingController.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/25.
//

import UIKit
import SwiftUI

/// fixSafeAreaInsets を一度だけ実行するためのフラグ
private var fixSafeAreaInsetsHostingControllerIsFixed = false

/// UIHostingController の view のレイアウトが safe area の影響を受けてしまう問題のワークアラウンドのために利用する
public final class FixSafeAreaInsetsHostingController<Content: View>: UIHostingController<Content> {

    override public init(rootView: Content) {
        super.init(rootView: rootView)
        if !fixSafeAreaInsetsHostingControllerIsFixed {
            fixSafeAreaInsets()
            fixSafeAreaInsetsHostingControllerIsFixed = true
        }
    }

    @available(*, unavailable)
    @objc dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// view の safe area を強制的になくす
    private func fixSafeAreaInsets() {
        let viewClass: AnyClass = view.classForCoder

        let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { (_: AnyObject!) -> UIEdgeInsets in
            .zero
        }
        guard let safeAreaInsetsMethod = class_getInstanceMethod(viewClass.self, #selector(getter: UIView.safeAreaInsets)) else { return }
        class_replaceMethod(viewClass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(safeAreaInsetsMethod))

        let safeAreaLayoutGuide: @convention(block) (AnyObject) -> UILayoutGuide? = { (_: AnyObject!) -> UILayoutGuide? in
            nil
        }
        guard let safeAreaLayoutGuideMethod = class_getInstanceMethod(viewClass.self, #selector(getter: UIView.safeAreaLayoutGuide)) else { return }
        class_replaceMethod(viewClass, #selector(getter: UIView.safeAreaLayoutGuide), imp_implementationWithBlock(safeAreaLayoutGuide), method_getTypeEncoding(safeAreaLayoutGuideMethod))
    }

}
