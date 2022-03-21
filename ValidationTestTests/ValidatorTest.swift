//
//  ValidatorTest.swift
//  ValidationTestTests
//
//  Created by Masato Takamura on 2021/12/18.
//

import XCTest
@testable import ValidationTest

class ValidatorTest: XCTestCase {

    private func isValid(_ result: ValidationResult) throws -> Bool {
        switch result {
        case .valid:
            return true
        case .invalid(let error):
            throw error
        }
    }

    func testEmailValidator() {
        let emailValidator = EmailValidator()
        let emailValid = "hoge@google.jp"
        let emailEmpty = ""
        let emailInvalidFormat = "hogehogehoge"
        XCTAssertNoThrow(try isValid(emailValidator.validate(emailValid)), "成功ケースを正常に検出できていません")
        XCTAssertThrowsError(try isValid(emailValidator.validate(emailEmpty)), "エラーが投げられていません。") { error in
            XCTAssertEqual(error as! EmailValidationError, EmailValidationError.empty, "EmailValidationError.emptyが投げられていません")
        }
        XCTAssertThrowsError(try isValid(emailValidator.validate(emailInvalidFormat)), "エラーが投げられていません。") { error in
            XCTAssertEqual(error as! EmailValidationError, EmailValidationError.invalidFormat, "EmailValidationError.invalidFormatが投げられていません")
        }
    }

    func testPasswordValidator() {
        let passwordValidator = PasswordValidator()
        let passwordEmpty = ""
        XCTAssertThrowsError(try isValid(passwordValidator.validate(passwordEmpty)), "エラーが投げられていません。") { error in
            XCTAssertEqual(error as! PasswordValidationError, PasswordValidationError.empty, "PasswordValidationError.emptyが投げられていません")
        }
    }

}
