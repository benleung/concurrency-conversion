//
//  ConversionResultCell.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/25.
//

import SwiftUI

struct ConversionResultCell: HostingCellContent {
    public typealias Dependency = Model

    public struct Model: Hashable {
        let currencyAlias: String
        let currencyName: String
        let amount: String
    }
    let model: Model

    public init(_ model: Model) {
        self.model = model
    }

    public var body: some View {
        VStack {
            Text(model.amount)
                .font(.body)
            Text(model.currencyAlias)
                .font(.headline)
            Text(model.currencyName)
                .font(.footnote)
        }
        .padding(10)
        .frame(width: 115, height: 115)
        .background(Color.white)
        .cornerRadius(4)
        .clipped()
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}
