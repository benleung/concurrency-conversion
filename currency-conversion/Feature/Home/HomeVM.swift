//
//  HomeVM.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/24.
//

import Combine
import UIKit

struct HomeVMInput {
    var amount = PassthroughSubject<Float, Never>()
    var didTapCurrencyDropDownView = PassthroughSubject<Void, Never>()
}
protocol HomeVMOutput {
    var openCurrencySelectModal: AnyPublisher<Void, Never> { get }
    var snapshot: AnyPublisher<HomeModel.Snapshot, Never> { get }
}

final class HomeVM: HomeVMOutput {
    private let input: HomeVMInput
    private var cancellables = Set<AnyCancellable>()

    // MARK: Output
    lazy var openCurrencySelectModal = {
        input.didTapCurrencyDropDownView.eraseToAnyPublisher()
    }()

    lazy var snapshot: AnyPublisher<HomeModel.Snapshot, Never> = {
        return _snapshot.eraseToAnyPublisher()
    }()
    private var _snapshot = CurrentValueSubject<HomeModel.Snapshot, Never>(HomeModel.Snapshot())

    init(input: HomeVMInput) {
        self.input = input
        
        // FIXME: WIP starts
        var snapshot = HomeModel.Snapshot()
        
        var items: [ConversionResultCell.Model] = []
        
        for i in 0..<200 {
            items.append(ConversionResultCell.Model(
                currencyAlias: "USD",
                currencyName: "US Dollars",
                amount: "\(i),456"
            ))
        }

        snapshot.appendSections([.currencyBlockGrid])
        snapshot.appendItems(items.map { HomeModel.Item.currencyBlock($0) })
        
        _snapshot.send(snapshot)
        // FIXME: WIP ends
        
        input.amount.sink {
            print($0)
        }
        .store(in: &cancellables)
    }
}
