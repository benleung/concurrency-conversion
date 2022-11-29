//
//  HomeViewController.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/24.
//

import UIKit
import Combine
import SwiftUI
import Core

/// ViewController of Home
/// Responsible for the actual operation required to update the UI
/// Independent of the business logic to generate data for Home's UI
final class HomeViewController: UIViewController {

    private var input: HomeViewModelInput
    private var output: HomeViewModelOutput

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
    
    private var amountInputTextField: NumberInputTextField = {
        let view = NumberInputTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Enter the currency amount here"
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.borderStyle = .roundedRect
        return view
    }()

    private var currencySelectButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        view.setTitle("USD", for: .normal)
        view.setTitleColor(.systemBlue, for: .normal)
        view.semanticContentAttribute = .forceRightToLeft
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return view
    }()

    private var emptyView: UIView = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Please enter currency amount \nto display a list of currency"
        view.textColor = .darkGray
        view.numberOfLines = 2
        view.textAlignment = .center
        view.layoutMargins = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        return view
    }()

    private var errorView: UIView = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "An error has occurred. Please make sure \nyou're connected to the Internet."
        view.textColor = .darkGray
        view.numberOfLines = 2
        view.textAlignment = .center
        view.layoutMargins = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        return view
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<HomeModel.Section, HomeModel.Item> = {
        UICollectionViewDiffableDataSource<HomeModel.Section, HomeModel.Item>(collectionView: currencyListCollectionView, cellProvider: { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let self = self else { return nil }
            
            switch item {
            case .currencyItem(let model):
                let cell: HostingCell<CurrencyListItemView> = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(model, parent: self)
                return cell
            }
        })
    }()

    private lazy var currencyListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        //  Size Adjust for iPod Touch
        let horizontalPadding: CGFloat = UIScreen.main.bounds.width > 370 ? 10 : 30
        
        layout.sectionInset = UIEdgeInsets(top: 10, left: horizontalPadding, bottom: 10, right: horizontalPadding)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(HostingCell<CurrencyListItemView>.self)
        collectionView.backgroundColor = .white
        return collectionView
    }()

    private var cancellables = Set<AnyCancellable>()

    init() {
        input = HomeViewModelInput()
        output = HomeViewModel(input: input)

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
        container.addArrangedSubview(currencyListCollectionView)
        container.addArrangedSubview(emptyView)
        container.addArrangedSubview(errorView)
        
        headerHStack.addArrangedSubview(amountInputTextField)
        headerHStack.addArrangedSubview(currencySelectButton)
        
        view.backgroundColor = .white
        
        setupConstrainst()
        binding()
    }

    private func setupConstrainst() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.0),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            container.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0),
            container.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0),
            currencySelectButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func binding() {
        // MARK: Input Binding
        
        // debounce() is used to prevent UI overburdening fo displaying a list of currency and input process of each character (by publishing input amount update only after a 0.5 seconds)
        amountInputTextField.numberPublisher.debounce(for: 0.5, scheduler: DispatchQueue.main).sink { [weak self] in
            self?.input.didUpdateAmount.send($0)
        }.store(in: &cancellables)
        
        currencySelectButton.publisher(for: .touchUpInside).sink { [weak self] _ in
            self?.input.didTapCurrencyDropDownView.send()
        }.store(in: &cancellables)        
        
        // MARK: Output Binding

        output.selectedCurrencyUnit
            .sink { [weak self] in
                self?.currencySelectButton.setTitle($0, for: .normal)
            }.store(in: &cancellables)

        output.openCurrencySelectModal
            .sink { [weak self] in
                guard let self = self else { return }

                let currencySelectView = CurrencySelectView(items: $0.list, selectedCurrencyUnit: $0.selected) {
                    self.input.didSelectedCurrency.send($0)
                }
                let vc = UIHostingController(rootView: currencySelectView)
                self.present(vc, animated: true)
            }.store(in: &cancellables)

        output.displayMode.sink { [weak self] in
            self?.currencyListCollectionView.isHidden = $0 != .currencyList
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
