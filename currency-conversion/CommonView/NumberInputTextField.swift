//
//  NumberInputTextField.swift
//  currency-conversion
//
//  Created by Ben Leung on 2022/11/24.
//

import UIKit
import Combine

final class NumberInputTextField: UITextField {
    init() {
        super.init(frame: .zero)
        keyboardType = .numberPad
        delegate = self
        autocorrectionType = .no
        spellCheckingType = .no
    }

    func makeNumberString(from str: String) -> String {
        guard let double = Double(str.replacingOccurrences(of: "^\\.", with: "0\\.", options: .regularExpression, range: nil)) else {
            return "0"
        }
        if double == -0.0 || double == 0.0 {
            return "0"
        }
        return String(double).replacingOccurrences(of: "\\.0$", with: "", options: .regularExpression, range: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    func configure(value: Double?) {
//        if let v = value {
//            text = makeNumberString(from: String(v))
//        } else {
//            text = makeNumberString(from: "0")
//        }
//    }
}

extension NumberInputTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
//        guard let currentText = text else {
//            text = ""
//            return
//        }
//        text = (currentText == "0" || currentText == "0.0") ? "" : makeNumberString(from: currentText)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        guard let text = textField.text, !text.isEmpty else {
            textField.text = makeNumberString(from: "0.0")
            return
        }
        
        let str = makeNumberString(from: text)
        textField.text = str
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text, let textRange = Range(range, in: text) else {
           return false
        }

        // FIMXE: side effect
        self.text = deleteUnneccessaryString(currentString: text, replacementString: string)
        
        // check whether should change characters
        let updatedText = text.replacingCharacters(in: textRange, with: string)
        return (updatedText.isEmpty) || (isValidTextLength(text: updatedText) && isValidDecimalString(text: updatedText))
    }

    // FIXME: to be determined
    // FIXME: should open for testing
    private func isValidTextLength(text: String) -> Bool {
        return text.lengthOfBytes(using: .utf8) < 11
    }

    private func deleteUnneccessaryString(currentString: String, replacementString: String) -> String {
        if currentString == "0", replacementString != "." {
            return currentString.replacingOccurrences(of: "0", with: "")
        }
        return currentString
    }

    private func isValidDecimalString(text: String) -> Bool {
        return (text.range(of: "^(-)?([0-9]*)?(\\.)?([0-9]*)?$", options: .regularExpression) != nil || text.isEmpty)
            && text.range(of: "^00+", options: .regularExpression) == nil
            && text.range(of: "^-\\.", options: .regularExpression) == nil
            // && text.occurrenceCount(of: ".") < 2
            && text.range(of: "\\.(.+){2,}", options: .regularExpression) == nil
    }
}


extension NumberInputTextField {

    var numberPublisher: AnyPublisher<Double?, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .compactMap { ($0.object as? UITextField)?.text }
        .map { Double($0) }
        .eraseToAnyPublisher()
    }

}
