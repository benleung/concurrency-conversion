//
//  CurrencySelectModalVC.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/26.
//

import SwiftUI

/// A view showing a list of currency symbol for selecting
struct CurrencySelectView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    private let selectedCurrencyUnit: String
    private let onSelectRow: (String) -> Void
    private let items: [Item]

    public struct Item: Hashable {
        let currencyAlias: String
        let currencyNameWithAlias: String
    }

    public init(items: [Item], selectedCurrencyUnit: String, onSelectRow: @escaping (String) -> Void) {
        self.items = items
        self.selectedCurrencyUnit = selectedCurrencyUnit
        self.onSelectRow = onSelectRow
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
                ForEach(items.filter { CurrencySelectView.filterWithSearchText(searchText: searchText, itemText: $0.currencyNameWithAlias) } , id: \.self) { model in
                    Button {
                        onSelectRow(model.currencyAlias)
                        presentationMode.wrappedValue.dismiss()
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
