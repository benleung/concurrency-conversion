//
//  CurrencySelectModalVC.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import Foundation

import SwiftUI

struct CurrencySelectView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    var selectedCurrencyUnit: String

    public struct Model: Hashable {
        let currencyAlias: String
        let currencyNameWithAlias: String
    }
    let models: [Model]
    let input: HomeVMInput

    public init(_ models: [Model], input: HomeVMInput, selectedCurrencyUnit: String) {
        self.models = models
        self.input = input
        self.selectedCurrencyUnit = selectedCurrencyUnit
    }

    public var body: some View {
        VStack {
            HStack {
                TextField("Search for your currency", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
            List {
                ForEach(models, id: \.self) { model in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        input.didSelectedCurrency.send(model.currencyAlias)
                    } label: {
                        HStack {
                            Text(model.currencyNameWithAlias)
                                .foregroundColor(Color.black)
                            if selectedCurrencyUnit == model.currencyAlias {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color.blue)
                            }
                        }
                    }
                }
            }
            
        }
    }
}
