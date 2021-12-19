//
//  ValidatorTest.swift
//  ValidationTestTests
//
//  Created by Masato Takamura on 2021/12/18.
//

import XCTest
@testable import ValidationTest
//@testable import ValidationTest

class ValidatorTest: XCTestCase {

    private func isValid(_ result: ValidationResult) throws -> Bool {
        switch result {
        case .valid:
            return true
        case .invalid(let error):
            throw error
        }
    }

    func testNameValidator() {
        let validator = CompositeValidatorFactory.shared.nameValidator()
        let nameValid = "田中太郎"
        let nameEmpty = ""
        let nameLengthOver20 = "長い氏名長い氏名長い氏名長い氏名長い氏名長い氏名"
        let nameFalseFormat = "korehahankakudesu"
        XCTAssertNoThrow(try isValid(validator.validate(nameValid)), "成功ケースを正常に検出できていません")
        XCTAssertThrowsError(try isValid(validator.validate(nameEmpty)), "エラーが投げられていません。") { error in
            XCTAssertEqual(error as! ValidationError, ValidationError.empty, "ValdationError.emptyが投げられていません")
        }
        XCTAssertThrowsError(try isValid(validator.validate(nameLengthOver20)), "エラーが投げられていません。") { error in
            XCTAssertEqual(error as! ValidationError, ValidationError.length(min: 1, max: 20), "ValdationError.length(min: 1, max: 20)が投げられていません")
        }
        XCTAssertThrowsError(try isValid(validator.validate(nameFalseFormat)), "エラーが投げられていません。") { error in
            XCTAssertEqual(error as! ValidationError, ValidationError.notFullWidth, "ValdationError.fullWidthが投げられていません")
        }
    }

}
