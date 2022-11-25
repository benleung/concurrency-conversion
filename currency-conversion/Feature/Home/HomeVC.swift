//
//  HomeVC.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/24.
//

import UIKit
import Combine

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
        return stackview
    }()
    
    private var amountInputView: NumberInputTextField = {
        let view = NumberInputTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Enter the currency amount here"
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
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

    private lazy var dataSource: UICollectionViewDiffableDataSource<HomeModel.Section, HomeModel.Item> = {
        UICollectionViewDiffableDataSource<HomeModel.Section, HomeModel.Item>(collectionView: conversionResultCollection, cellProvider: { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let self = self else { return nil }
            
            switch item {
            case .currencyBlock(let model):
                let cell: Cell = collectionView.dequeueReusableCell(for: indexPath)
                cell.configure(model, parent: self)
                return cell
            }
        })
    }()
    
    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        layout.itemSize = CGSize(width: 115, height: 115)
//        layout.estimatedItemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return layout
    }()
    

    typealias Cell = HostingCell<ConversionResultCell>
    
    private lazy var conversionResultCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.backgroundColor = .blue
        collectionView.register(Cell.self)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(container)
        
        container.addArrangedSubview(headerHStack)
        container.addArrangedSubview(conversionResultCollection)
        
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
            container.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10.0),
            container.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10.0)
        ])
    }

    private func binding() {
        // Input
        amountInputView.numberPublisher.sink { [weak self] in
            self?.input.amount.send($0)
        }.store(in: &cancellables)
        
        currencyDropdownButton.publisher(for: .touchUpInside).sink { [weak self] _ in
            self?.input.didTapCurrencyDropDownView.send()
        }.store(in: &cancellables)

        // Output
        output.openCurrencySelectModal.sink {
            print("openCurrencySelectModal")
        }.store(in: &cancellables)
        
        output.snapshot.sink { [weak self] in
            self?.dataSource.apply($0)
        }.store(in: &cancellables)
    }
}
