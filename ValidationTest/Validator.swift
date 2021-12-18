//
//  Validator.swift
//  ValidationTest
//
//  Created by Masato Takamura on 2021/10/22.
//

import Foundation


enum ValidationResult {
    case valid
    case invalid(ValidationError)
}

enum ValidationError: Error, Equatable {
    case empty
    case length(min: Int, max: Int)
    case notFullWidth
    case notHalfWidthAlphanumeric
    case notHalfWidthNumeric

    var description: String {
        switch self {
        case .empty:
            return "文字を入力してください"
        case .length(let min, let max):
            return "文字数を\(min)文字以上、\(max)文字以下で入力してください"
        case .notFullWidth:
            return "全角文字のみで入力してください"
        case .notHalfWidthAlphanumeric:
            return "半角英数字のみで入力してください"
        case .notHalfWidthNumeric:
            return "半角数字のみで入力してください"
        }
    }
}

protocol Validator {
    func validate(_ text: String) -> ValidationResult
}

protocol CompositeValidator: Validator {
    var validators: [Validator] { get }
    func validate(_ text: String) -> ValidationResult
}

extension CompositeValidator {
    private func validate(_ text: String) -> [ValidationResult] {
        return validators.map { $0.validate(text) }
    }

    ///Use this.
    func validate(_ text: String) -> ValidationResult {
        let results: [ValidationResult] = validate(text)
        //全てのValidatorでバリデーションし、エラーを吐いたものを返す。なければ.valid。
        let errors = results.filter { result -> Bool in
            switch result {
            case .valid:
                return false
            case .invalid:
                return true
            }
        }
        return errors.first ?? .valid
    }
}

//MARK: - Create validators
//必須項目
struct EmptyValidator: Validator {
    func validate(_ text: String) -> ValidationResult {
        if text.isEmpty {
            return .invalid(.empty)
        } else {
            return .valid
        }
    }
}

//min文字以上、max文字以内の文字数制限
struct LengthValidator: Validator {

    let min: Int
    let max: Int

    func validate(_ text: String) -> ValidationResult {
        if text.count >= min && text.count <= max {
            return .valid
        } else {
            return .invalid(.length(min: min, max: max))
        }
    }
}

//全角
struct FullWidthValidator: Validator {
    func validate(_ text: String) -> ValidationResult {
        if text.isInvalid(textType: .fullWidth) {
            return .invalid(.notFullWidth)
        } else {
            return .valid
        }
    }
}

//半角英数字
struct HalfWidthAlphanumericValidator: Validator {
    func validate(_ text: String) -> ValidationResult {
        if text.isInvalid(textType: .halfWidthAlphanumeric) {
            return .invalid(.notHalfWidthAlphanumeric)
        } else {
            return .valid
        }
    }
}

//半角数字
struct HalfWidthNumericValidator: Validator {
    func validate(_ text: String) -> ValidationResult {
        if text.isInvalid(textType: .halfWidthNumeric) {
            return .invalid(.notHalfWidthNumeric)
        } else {
            return .valid
        }
    }
}


//MARK: - Create composite validators
struct NameCompositeValidator: CompositeValidator {
    var validators: [Validator] = [
        EmptyValidator(),
        LengthValidator(min: 1, max: 20),
        FullWidthValidator()
    ]
}

//MARK: - 文字タイプのEnum
enum TextType {
    case fullWidth      //全角
    case fullWidthHiragana      //全角ひらがな
    case fullwidthKatakana      //全角カタカナ
    case halfWidthAlphanumeric      //半角英数
    case halfWidthNumeric       //半角数字
    case halfWidthAlphabetic        //半角英字
    case halfWidthUpperAlphabetic       //半角英字 (大文字)
    case halfWidthLowerAlphabetic       //半角英字 (小文字)
}

//MARK: - 正規表現による文字の判別メソッドの追加
private extension String {
    func isInvalid(textType: TextType) -> Bool {
        switch textType {
            //全角 (＝１バイトの文字\x01-\x7Eと半角カナ\uFF61-\uFF9F以外)
        case .fullWidth:
            return range(of: "^[^\\x01-\\x7E\\uFF61-\\uFF9F]+$", options: .regularExpression) == nil
            //全角ひらがな
        case .fullWidthHiragana:
            return range(of: "^[\\u3041-\\u3096F]+$", options: .regularExpression) == nil
            //全角カタカナ
        case .fullwidthKatakana:
            return range(of: "^[\\u30a1-\\u30f6]+$", options: .regularExpression) == nil
            //半角英数字
        case .halfWidthAlphanumeric:
            return range(of: "^[a-zA-Z0-9]+$", options: .regularExpression) == nil
            //半角数字
        case .halfWidthNumeric:
            return range(of: "^[0-9]+$", options: .regularExpression) == nil
            //半角英字
        case .halfWidthAlphabetic:
            return range(of: "^[a-zA-Z]+$", options: .regularExpression) == nil
            //半角英字 (大文字)
        case .halfWidthUpperAlphabetic:
            return range(of: "^[A-Z]+$", options: .regularExpression) == nil
            //半角英字 (小文字)
        case .halfWidthLowerAlphabetic:
            return range(of: "^[a-z]+$", options: .regularExpression) == nil
        }
    }
}
