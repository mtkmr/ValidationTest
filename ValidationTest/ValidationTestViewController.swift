//
//  ValidationTestViewController.swift
//  ValidationTest
//
//  Created by Masato Takamura on 2021/10/22.
//

import UIKit

final class ValidationTestViewController: UIViewController {

    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Validation Test"
        setupTextField()
    }

    private func setupTextField() {
        textField.delegate = self
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.gray.cgColor
    }

    private func changeUIPartsAppearance(result: ValidationResult) {
        switch result {
        case .valid:
            textField.layer.borderColor = UIColor.gray.cgColor
            resultLabel.textColor = .label
        case .invalid(_):
            textField.layer.borderColor = UIColor.red.cgColor
            resultLabel.textColor = .red
        }
    }

}

extension ValidationTestViewController: UITextFieldDelegate {
    ///Enterを押したとき
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //CompositeValidatorを使用する
        let validator = NameCompositeValidator()
        let result: ValidationResult = validator.validate(textField.text ?? "")
        changeUIPartsAppearance(result: result)
        switch result {
        case .valid:
            resultLabel.text = "😄"
            print("OK")
        case .invalid(let error):
            resultLabel.text = error.description
            print("Invalid text for reason: \(error.description)")
        }

        return true
    }
}
