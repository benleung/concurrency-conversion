//
//  CurrencySelectModalVC.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import Foundation

import SwiftUI

/// A view showing a list of currency symbol for selecting
struct CurrencySelectView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    var selectedCurrencyUnit: String

    public struct Model: Hashable {
        let currencyAlias: String
        let currencyNameWithAlias: String
    }
    let models: [Model]
    let input: HomeViewModelInput

    public init(_ models: [Model], input: HomeViewModelInput, selectedCurrencyUnit: String) {
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
                ForEach(models.filter { CurrencySelectView.filterWithSearchText(searchText: searchText, itemText: $0.currencyNameWithAlias) } , id: \.self) { model in
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
    
    // open visibility to interal for testing
    static func filterWithSearchText(searchText: String, itemText: String) -> Bool {
        searchText.isEmpty || itemText.contains(searchText)
    }
}
