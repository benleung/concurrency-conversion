//
//  NumberInputTextField.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/24.
//

import UIKit
import Combine

public final class NumberInputTextField: UITextField {
    public init() {
        super.init(frame: .zero)
        keyboardType = .decimalPad
        delegate = self
        autocorrectionType = .no
        spellCheckingType = .no
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NumberInputTextField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text, let textRange = Range(range, in: text) else {
           return false
        }
        
        // check whether should change characters
        let updatedText = text.replacingCharacters(in: textRange, with: string)
        return isValidDecimalString(text: updatedText)
    }

    // internal visibility for unit test
    func isValidDecimalString(text: String) -> Bool {
        return text.range(of: "^\\d*.?\\d*$", options: .regularExpression) != nil || text.isEmpty
    }
}

extension NumberInputTextField {
    public var numberPublisher: AnyPublisher<Double?, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .compactMap { ($0.object as? UITextField)?.text }
        .map { Double($0) }
        .eraseToAnyPublisher()
    }

}
