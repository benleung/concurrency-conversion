//
//  CurrencyListItemView.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/25.
//

import SwiftUI
import Core

/// a currency block containing calcuated amount, current symbol and full name
struct CurrencyListItemView: HostingCellContent {
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
                .foregroundColor(Color.gray)
                .font(.footnote)
        }
        .padding(10)
        .frame(width: 110, height: 110, alignment: .top)
        .background(Color.white)
        .cornerRadius(6)
        .clipped()
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 2,
            x: 2,
            y: 2
        )
    }
}
