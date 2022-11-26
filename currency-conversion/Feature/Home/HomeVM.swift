//
//  HomeVM.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/24.
//

import Combine
import UIKit

struct HomeVMInput {
    var amount = PassthroughSubject<Double, Never>()
    var didTapCurrencyDropDownView = PassthroughSubject<Void, Never>()
    var didSelectedCurrency = PassthroughSubject<String, Never>()
    var viewWillAppear = PassthroughSubject<Void, Never>()
}
protocol HomeVMOutput {
    var openCurrencySelectModal: AnyPublisher<(list: [CurrencySelectView.Model], selected: String), Never> { get }
    var selectedCurrencyUnit: AnyPublisher<String, Never> { get }   // use viewstate instead of 
    var snapshot: AnyPublisher<HomeModel.Snapshot, Never> { get }
}

final class HomeVM: HomeVMOutput {
    private let input: HomeVMInput
    private var cancellables = Set<AnyCancellable>()

    // MARK: Output
    lazy var openCurrencySelectModal = {
        input.didTapCurrencyDropDownView
            .map { Void -> (list: [CurrencySelectView.Model], selected: String) in
                var items: [CurrencySelectView.Model] = []
                
                let symbols = AppUserDefaults.shared.exchangeRates.keys.sorted()
                let exchangeRates = AppUserDefaults.shared.exchangeRates
                let currencyNames = AppUserDefaults.shared.currencyNames
                
                for symbol in symbols {
                    items.append(CurrencySelectView.Model(
                        currencyAlias: symbol,
                        currencyNameWithAlias: "\(symbol) (\(currencyNames[symbol] ?? "-"))"
                    ))
                }
                return (list: items, selected: self._selectedCurrencyUnit.value)
            }
            .eraseToAnyPublisher()
    }()

    lazy var selectedCurrencyUnit: AnyPublisher<String, Never> = {
        _selectedCurrencyUnit.eraseToAnyPublisher()
    }()
    private var _selectedCurrencyUnit = CurrentValueSubject<String, Never>("USD")

    lazy var snapshot: AnyPublisher<HomeModel.Snapshot, Never> = {
        return _snapshot.eraseToAnyPublisher()
    }()
    private var _snapshot = CurrentValueSubject<HomeModel.Snapshot, Never>(HomeModel.Snapshot())

    // MARK: private properties
    private var exchangeRates = CurrentValueSubject<[String: Double]?, Never>(nil)
    private var currencyNames = CurrentValueSubject<[String: String]?, Never>(nil)
    
    init(input: HomeVMInput) {
        self.input = input
        
        // snapshot
        Publishers.CombineLatest4(
            exchangeRates.compactMap { $0 },
            currencyNames.compactMap { $0 },
            selectedCurrencyUnit,
            input.amount
        )
            .sink { [weak self] exchangeRates, currencyNames, selectedCurrencyUnit, amount in
                guard let self = self else {
                    return
                }

                var snapshot = HomeModel.Snapshot()
                var items: [ConversionResultCell.Model] = []

                for currencySymbol in exchangeRates.keys.sorted() {
                    if let currencyName = currencyNames[currencySymbol],
                       let calculatedAmount = self.getCurrencyAmount(from: selectedCurrencyUnit, to: currencySymbol, exchangeRates: exchangeRates, fromAmount: amount)
                    {
                        
                        items.append(ConversionResultCell.Model(
                            currencyAlias: currencySymbol,
                            currencyName: currencyName,
                            amount: "\(calculatedAmount)"
                        ))
                    }
                }

                snapshot.appendSections([.currencyBlockGrid])
                snapshot.appendItems(items.map { HomeModel.Item.currencyBlock($0) })
                self._snapshot.send(snapshot)
            }
            .store(in: &cancellables)
        
        // FIXME: WIP ends
        
        // side effects
        input.viewWillAppear.sink {
            AppUserDefaults.shared.exchangeRates = [
                "AED": 3.673035,
                "AFN": 89.092584,
                "ALL": 113.264792,
                "AMD": 395.568993,
                "ANG": 1.802499,
                "AOA": 508.05415,
                "ARS": 164.493491,
                "AUD": 1.503474,
                "AWG": 1.8,
                "AZN": 1.7,
                "BAM": 1.895496,
                "BBD": 2,
                "BDT": 102.025311,
                "BGN": 1.896024,
                "BHD": 0.376991,
                "BIF": 2070.341976,
                "BMD": 1,
                "BND": 1.384801,
                "BOB": 6.911019,
                "BRL": 5.3839,
                "BSD": 1,
                "BTC": 0.000060637316,
                "BTN": 81.852308,
                "BWP": 12.938571,
                "BYN": 2.525501,
                "BZD": 2.016,
                "CAD": 1.341523,
                "CDF": 2055.340416,
                "CHF": 0.949523,
                "CLF": 0.033599,
                "CLP": 927.1,
                "CNH": 7.17291,
                "CNY": 7.1645,
                "COP": 4906.526281,
                "CRC": 606.990602,
                "CUC": 1,
                "CUP": 25.75,
                "CVE": 107.63,
                "CZK": 23.595495,
                "DJF": 178.052585,
                "DKK": 7.204502,
                "DOP": 54.309773,
                "DZD": 138.881018,
                "EGP": 24.5295,
                "ERN": 15,
                "ETB": 53.433999,
                "EUR": 0.968674,
                "FJD": 2.23175,
                "FKP": 0.837399,
                "GBP": 0.837399,
                "GEL": 2.715,
                "GGP": 0.837399,
                "GHS": 14.502389,
                "GIP": 0.837399,
                "GMD": 61.55,
                "GNF": 8618.303669,
                "GTQ": 7.79119,
                "GYD": 209.246558,
                "HKD": 7.81686,
                "HNL": 24.712046,
                "HRK": 7.3076,
                "HTG": 137.500281,
                "HUF": 393.145,
                "IDR": 15686.412255,
                "ILS": 3.452746,
                "IMP": 0.837399,
                "INR": 81.783501,
                "IQD": 1459.71209,
                "IRR": 42400,
                "ISK": 142.1,
                "JEP": 0.837399,
                "JMD": 154.287666,
                "JOD": 0.7099,
                "JPY": 141.26873333,
                "KES": 122.31,
                "KGS": 84.073223,
                "KHR": 4136.651943,
                "KMF": 478.500071,
                "KPW": 900,
                "KRW": 1353.481179,
                "KWD": 0.307915,
                "KYD": 0.833459,
                "KZT": 464.940933,
                "LAK": 17300.760468,
                "LBP": 1512.242045,
                "LKR": 365.5548,
                "LRD": 153.99998,
                "LSL": 17.179089,
                "LYD": 4.922031,
                "MAD": 10.736167,
                "MDL": 19.253171,
                "MGA": 4334.709981,
                "MKD": 59.714296,
                "MMK": 2100.32228,
                "MNT": 3406.965265,
                "MOP": 8.052469,
                "MRU": 38.036673,
                "MUR": 43.649506,
                "MVR": 15.365,
                "MWK": 1026.572913,
                "MXN": 19.383469,
                "MYR": 4.575,
                "MZN": 63.899991,
                "NAD": 17.26,
                "NGN": 440.576775,
                "NIO": 36.00056,
                "NOK": 10.04279,
                "NPR": 130.963475,
                "NZD": 1.620128,
                "OMR": 0.38449,
                "PAB": 1,
                "PEN": 3.846799,
                "PGK": 3.524093,
                "PHP": 57.060505,
                "PKR": 224.433618,
                "PLN": 4.555451,
                "PYG": 7195.212431,
                "QAR": 3.660531,
                "RON": 4.7824,
                "RSD": 113.668124,
                "RUB": 60.674996,
                "RWF": 1081.07857,
                "SAR": 3.758423,
                "SBD": 8.223823,
                "SCR": 12.754272,
                "SDG": 568.5,
                "SEK": 10.554975,
                "SGD": 1.384583,
                "SHP": 0.837399,
                "SLL": 17665,
                "SOS": 568.601264,
                "SRD": 30.772,
                "SSP": 130.26,
                "STD": 22823.990504,
                "STN": 23.955,
                "SVC": 8.751314,
                "SYP": 2512.53,
                "SZL": 17.179865,
                "THB": 36.2425,
                "TJS": 10.051656,
                "TMT": 3.51,
                "TND": 3.255,
                "TOP": 2.372969,
                "TRY": 18.6284,
                "TTD": 6.788616,
                "TWD": 31.181502,
                "TZS": 2332,
                "UAH": 36.937576,
                "UGX": 3740.640155,
                "USD": 1,
                "UYU": 39.556332,
                "UZS": 11224.581515,
                "VES": 9.9662,
                "VND": 24850.896167,
                "VUV": 122.25878,
                "WST": 2.793855,
                "XAF": 635.408528,
                "XAG": 0.04725907,
                "XAU": 0.00057587,
                "XCD": 2.70255,
                "XDR": 0.743991,
                "XOF": 635.408528,
                "XPD": 0.00053221,
                "XPF": 115.593563,
                "XPT": 0.00100886,
                "YER": 250.324952,
                "ZAR": 17.15826,
                "ZMW": 16.802768,
                "ZWL": 322
              ]
            AppUserDefaults.shared.currencyNames = [
                "AED": "United Arab Emirates Dirham",
                "AFN": "Afghan Afghani",
                "ALL": "Albanian Lek",
                "AMD": "Armenian Dram",
                "ANG": "Netherlands Antillean Guilder",
                "AOA": "Angolan Kwanza",
                "ARS": "Argentine Peso",
                "AUD": "Australian Dollar",
                "AWG": "Aruban Florin",
                "AZN": "Azerbaijani Manat",
                "BAM": "Bosnia-Herzegovina Convertible Mark",
                "BBD": "Barbadian Dollar",
                "BDT": "Bangladeshi Taka",
                "BGN": "Bulgarian Lev",
                "BHD": "Bahraini Dinar",
                "BIF": "Burundian Franc",
                "BMD": "Bermudan Dollar",
                "BND": "Brunei Dollar",
                "BOB": "Bolivian Boliviano",
                "BRL": "Brazilian Real",
                "BSD": "Bahamian Dollar",
                "BTC": "Bitcoin",
                "BTN": "Bhutanese Ngultrum",
                "BWP": "Botswanan Pula",
                "BYN": "Belarusian Ruble",
                "BZD": "Belize Dollar",
                "CAD": "Canadian Dollar",
                "CDF": "Congolese Franc",
                "CHF": "Swiss Franc",
                "CLF": "Chilean Unit of Account (UF)",
                "CLP": "Chilean Peso",
                "CNH": "Chinese Yuan (Offshore)",
                "CNY": "Chinese Yuan",
                "COP": "Colombian Peso",
                "CRC": "Costa Rican Colón",
                "CUC": "Cuban Convertible Peso",
                "CUP": "Cuban Peso",
                "CVE": "Cape Verdean Escudo",
                "CZK": "Czech Republic Koruna",
                "DJF": "Djiboutian Franc",
                "DKK": "Danish Krone",
                "DOP": "Dominican Peso",
                "DZD": "Algerian Dinar",
                "EGP": "Egyptian Pound",
                "ERN": "Eritrean Nakfa",
                "ETB": "Ethiopian Birr",
                "EUR": "Euro",
                "FJD": "Fijian Dollar",
                "FKP": "Falkland Islands Pound",
                "GBP": "British Pound Sterling",
                "GEL": "Georgian Lari",
                "GGP": "Guernsey Pound",
                "GHS": "Ghanaian Cedi",
                "GIP": "Gibraltar Pound",
                "GMD": "Gambian Dalasi",
                "GNF": "Guinean Franc",
                "GTQ": "Guatemalan Quetzal",
                "GYD": "Guyanaese Dollar",
                "HKD": "Hong Kong Dollar",
                "HNL": "Honduran Lempira",
                "HRK": "Croatian Kuna",
                "HTG": "Haitian Gourde",
                "HUF": "Hungarian Forint",
                "IDR": "Indonesian Rupiah",
                "ILS": "Israeli New Sheqel",
                "IMP": "Manx pound",
                "INR": "Indian Rupee",
                "IQD": "Iraqi Dinar",
                "IRR": "Iranian Rial",
                "ISK": "Icelandic Króna",
                "JEP": "Jersey Pound",
                "JMD": "Jamaican Dollar",
                "JOD": "Jordanian Dinar",
                "JPY": "Japanese Yen",
                "KES": "Kenyan Shilling",
                "KGS": "Kyrgystani Som",
                "KHR": "Cambodian Riel",
                "KMF": "Comorian Franc",
                "KPW": "North Korean Won",
                "KRW": "South Korean Won",
                "KWD": "Kuwaiti Dinar",
                "KYD": "Cayman Islands Dollar",
                "KZT": "Kazakhstani Tenge",
                "LAK": "Laotian Kip",
                "LBP": "Lebanese Pound",
                "LKR": "Sri Lankan Rupee",
                "LRD": "Liberian Dollar",
                "LSL": "Lesotho Loti",
                "LYD": "Libyan Dinar",
                "MAD": "Moroccan Dirham",
                "MDL": "Moldovan Leu",
                "MGA": "Malagasy Ariary",
                "MKD": "Macedonian Denar",
                "MMK": "Myanma Kyat",
                "MNT": "Mongolian Tugrik",
                "MOP": "Macanese Pataca",
                "MRU": "Mauritanian Ouguiya",
                "MUR": "Mauritian Rupee",
                "MVR": "Maldivian Rufiyaa",
                "MWK": "Malawian Kwacha",
                "MXN": "Mexican Peso",
                "MYR": "Malaysian Ringgit",
                "MZN": "Mozambican Metical",
                "NAD": "Namibian Dollar",
                "NGN": "Nigerian Naira",
                "NIO": "Nicaraguan Córdoba",
                "NOK": "Norwegian Krone",
                "NPR": "Nepalese Rupee",
                "NZD": "New Zealand Dollar",
                "OMR": "Omani Rial",
                "PAB": "Panamanian Balboa",
                "PEN": "Peruvian Nuevo Sol",
                "PGK": "Papua New Guinean Kina",
                "PHP": "Philippine Peso",
                "PKR": "Pakistani Rupee",
                "PLN": "Polish Zloty",
                "PYG": "Paraguayan Guarani",
                "QAR": "Qatari Rial",
                "RON": "Romanian Leu",
                "RSD": "Serbian Dinar",
                "RUB": "Russian Ruble",
                "RWF": "Rwandan Franc",
                "SAR": "Saudi Riyal",
                "SBD": "Solomon Islands Dollar",
                "SCR": "Seychellois Rupee",
                "SDG": "Sudanese Pound",
                "SEK": "Swedish Krona",
                "SGD": "Singapore Dollar",
                "SHP": "Saint Helena Pound",
                "SLL": "Sierra Leonean Leone",
                "SOS": "Somali Shilling",
                "SRD": "Surinamese Dollar",
                "SSP": "South Sudanese Pound",
                "STD": "São Tomé and Príncipe Dobra (pre-2018)",
                "STN": "São Tomé and Príncipe Dobra",
                "SVC": "Salvadoran Colón",
                "SYP": "Syrian Pound",
                "SZL": "Swazi Lilangeni",
                "THB": "Thai Baht",
                "TJS": "Tajikistani Somoni",
                "TMT": "Turkmenistani Manat",
                "TND": "Tunisian Dinar",
                "TOP": "Tongan Pa'anga",
                "TRY": "Turkish Lira",
                "TTD": "Trinidad and Tobago Dollar",
                "TWD": "New Taiwan Dollar",
                "TZS": "Tanzanian Shilling",
                "UAH": "Ukrainian Hryvnia",
                "UGX": "Ugandan Shilling",
                "USD": "United States Dollar",
                "UYU": "Uruguayan Peso",
                "UZS": "Uzbekistan Som",
                "VEF": "Venezuelan Bolívar Fuerte (Old)",
                "VES": "Venezuelan Bolívar Soberano",
                "VND": "Vietnamese Dong",
                "VUV": "Vanuatu Vatu",
                "WST": "Samoan Tala",
                "XAF": "CFA Franc BEAC",
                "XAG": "Silver Ounce",
                "XAU": "Gold Ounce",
                "XCD": "East Caribbean Dollar",
                "XDR": "Special Drawing Rights",
                "XOF": "CFA Franc BCEAO",
                "XPD": "Palladium Ounce",
                "XPF": "CFP Franc",
                "XPT": "Platinum Ounce",
                "YER": "Yemeni Rial",
                "ZAR": "South African Rand",
                "ZMW": "Zambian Kwacha",
                "ZWL": "Zimbabwean Dollar"
              ]
            
            self.exchangeRates.send(AppUserDefaults.shared.exchangeRates)
            self.currencyNames.send(AppUserDefaults.shared.currencyNames)
        }
        .store(in: &cancellables)
        
        // selectedCurrencyUnit
        input.didSelectedCurrency.sink {
            self._selectedCurrencyUnit.send($0)
        }
        .store(in: &cancellables)
        
        input.amount.sink {
            print($0)
        }
        .store(in: &cancellables)
    }

    private func getCurrencyAmount(from: String, to: String, exchangeRates: [String: Double], fromAmount: Double) -> Double? {
        guard let fromExchangeRate = exchangeRates[from], let toExchangeRate = exchangeRates[to] else { return nil}
        
        return (fromAmount / fromExchangeRate) * toExchangeRate
    }
    
}
