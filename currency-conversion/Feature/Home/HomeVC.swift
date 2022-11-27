//
//  HomeVC.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/24.
//

import UIKit
import Combine
import SwiftUI

final class HomeVC: UIViewController {

    private var input: HomeVMInput
    private var output: HomeVMOutput

    private var container: UIStackView  = {
        let stackview = UIStackView()
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.axis = .vertical
        stackview.spacing = 10.0
        return stackview
    }()

    private var headerHStack: UIStackView  = {
        let stackview = UIStackView()
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.axis = .horizontal
        stackview.spacing = 10.0
        stackview.isLayoutMarginsRelativeArrangement = true
        stackview.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return stackview
    }()
    
    private var amountInputView: NumberInputTextField = {
        let view = NumberInputTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Enter the currency amount here"
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.borderStyle = .roundedRect
        return view
    }()

    private var currencyDropdownButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        view.setTitle("USD", for: .normal)
        view.setTitleColor(.systemBlue, for: .normal)
        view.semanticContentAttribute = .forceRightToLeft
        
        return view
    }()

    private var emptyView: UIView = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Please enter currency amount to display a list of currency"
        view.numberOfLines = 2
        view.textAlignment = .center
        view.layoutMargins = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        return view
    }()

    private var errorView: UIView = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "An error has occurred. Please make sure you're connected to the Internet."
        view.numberOfLines = 2
        view.textAlignment = .center
        view.layoutMargins = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        return view
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<HomeModel.Section, HomeModel.Item> = {
        UICollectionViewDiffableDataSource<HomeModel.Section, HomeModel.Item>(collectionView: conversionResultCollection, cellProvider: { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let self = self else { return nil }
            
            switch item {
            case .currencyItem(let model):
                let cell: ConversionResultCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(model, parent: self)
                return cell
            }
        })
    }()
    
    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return layout
    }()
    

    typealias ConversionResultCell = HostingCell<ConversionResultView>
    
    private lazy var conversionResultCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ConversionResultCell.self)
        collectionView.backgroundColor = .white
        return collectionView
    }()

    private var cancellables = Set<AnyCancellable>()

    init() {
        input = HomeVMInput()
        output = HomeVM(input: input)

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        input.viewWillAppear.send()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(container)
        
        container.addArrangedSubview(headerHStack)
        container.addArrangedSubview(conversionResultCollection)
        container.addArrangedSubview(emptyView)
        container.addArrangedSubview(errorView)
        
        headerHStack.addArrangedSubview(amountInputView)
        headerHStack.addArrangedSubview(currencyDropdownButton)
        
        view.backgroundColor = .white
        
        setupConstrainst()
        binding()
    }

    private func setupConstrainst() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.0),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            container.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0),
            container.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0)
        ])
    }

    private func binding() {
        // Input
        amountInputView.numberPublisher.debounce(for: 0.5, scheduler: DispatchQueue.main).sink { [weak self] in
            self?.input.didUpdateAmount.send($0)
        }.store(in: &cancellables)
        
        currencyDropdownButton.publisher(for: .touchUpInside).sink { [weak self] _ in
            self?.input.didTapCurrencyDropDownView.send()
        }.store(in: &cancellables)        
        
        // Output
        output.selectedCurrencyUnit
            .sink {
                self.currencyDropdownButton.setTitle($0, for: .normal)
            }.store(in: &cancellables)
        
        output.openCurrencySelectModal
            .sink {
                let currencySelectView = CurrencySelectView($0.list, input: self.input, selectedCurrencyUnit: $0.selected)
                let vc = UIHostingController(rootView: currencySelectView)
                self.present(vc, animated: true)
            }.store(in: &cancellables)
        
        output.displayMode.sink { [weak self] in
            self?.conversionResultCollection.isHidden = $0 != .currencyList
            self?.emptyView.isHidden = $0 != .empty
            self?.errorView.isHidden = $0 != .error
        }.store(in: &cancellables)
        
        output.snapshot.sink { [weak self] snapshot in
            DispatchQueue.main.async {
                self?.dataSource.apply(snapshot)
            }
        }.store(in: &cancellables)
    }
}
