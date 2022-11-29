//
//  FixSafeAreaInsetsHostingController.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/25.
//

import UIKit
import SwiftUI

/// A wrapper for HostingController to work around a known bug that safe area affect the View's vertical location
public final class FixSafeAreaInsetsHostingController<Content: View>: UIHostingController<Content> {
    /// fixSafeAreaInsets() should only be called once only
    private var fixSafeAreaInsetsHostingControllerIsFixed = false
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

    /// remove view's safe area forcibly
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
