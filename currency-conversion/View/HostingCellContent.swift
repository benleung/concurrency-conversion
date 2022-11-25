//
//  HostingCellContent.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/25.
//

import SwiftUI
import UIKit

protocol HostingCellContent: View {
    associatedtype Dependency
    init(_ dependency: Dependency)
}

final class HostingCell<Content: HostingCellContent>: UICollectionViewCell {
    private let hostingController = UIHostingController<Content?>(rootView: nil)

    override public init(frame: CGRect) {
        super.init(frame: frame)
        hostingController.view.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(_ dependency: Content.Dependency, parent: UIViewController) {
        hostingController.rootView = Content(dependency)
//        hostingController.view.invalidateIntrinsicContentSize()
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        guard hostingController.parent == nil else { return }
        parent.addChild(hostingController)
        contentView.addSubview(hostingController.view)
        setupConstraints()
        hostingController.didMove(toParent: parent)
    }

    private func setupConstraints() {
        guard let view = hostingController.view, let superview = view.superview else { return }
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor),
            view.leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor),
            view.rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor)
        ])
    }
}
