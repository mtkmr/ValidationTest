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
    }

}

extension ValidationTestViewController: UITextFieldDelegate {
    ///Enterを押したとき
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //CompositeValidatorを使用する
        let validator = NameValidator()
        let result: ValidationResult = validator.validate(textField.text ?? "")
        switch result {
        case .valid:
            resultLabel.text = "😄"
            resultLabel.textColor = .label
            print("OK")
        case .invalid(let error):
            resultLabel.text = error.description
            resultLabel.textColor = .red
            print("\(error.description)")
        }

        return true
    }
}
