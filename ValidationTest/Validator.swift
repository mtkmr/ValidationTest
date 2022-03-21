//
//  Validator.swift
//  ValidationTest
//
//  Created by Masato Takamura on 2021/10/22.
//

import Foundation

// 参考: https://owensd.io/2016/11/28/composite-validators-refined/

//MARK: - Result
enum ValidationResult {
    case valid(String)
    case invalid(Error)
}

enum EmailValidationError: Error, Equatable {
    case empty
    case invalidLength(min: Int, max: Int)
    case invalidFormat

    var description: String {
        switch self {
        case .empty:
            return "メールアドレスを入力してください。"
        case .invalidLength(min: let min, max: let max):
            return "\(min)文字以上、\(max)文字以内で入力してください。"
        case .invalidFormat:
            return "フォーマットが正しくありません。"
        }
    }
}

enum PasswordValidationError: Error {
    case empty

    var description: String {
        switch self {
        case .empty:
            return "パスワードを入力してください。"
        }
    }
}

//MARK: - Protocols
protocol Validator {
    func validate(_ text: String) -> ValidationResult
}

protocol CompositeValidator: Validator {
    var validators: [Validator] { get }
    func validate(_ text: String) -> ValidationResult
}

extension CompositeValidator {
    private func validate(_ text: String) -> [ValidationResult] {
        validators.map { $0.validate(text) }
    }

    func validate(_ text: String) -> ValidationResult {
        let validationResults: [ValidationResult] = validate(text)
        let errors = validationResults.filter { result in
            if case .invalid = result {
                return true
            } else {
                return false
            }
        }
        return errors.first ?? .valid(text)
    }
}

// MARK: - Single Validator

struct EmailEmptyValidator: Validator {
    func validate(_ text: String) -> ValidationResult {
        text.isEmpty ? .invalid(EmailValidationError.empty) : .valid(text)
    }
}

struct EmailLengthValidator: Validator {
    let min: Int
    let max: Int
    func validate(_ text: String) -> ValidationResult {
        if text.count >= min && text.count <= max {
            return .valid(text)
        } else {
            return .invalid(EmailValidationError.invalidLength(min: min, max: max))
        }
    }
}

struct EmailFormatValidator: Validator {
    func validate(_ text: String) -> ValidationResult {
        text.isInvalid(textType: .emailFormat) ? .invalid(EmailValidationError.invalidFormat) : .valid(text)
    }
}

struct PasswordEmptyValidator: Validator {
    func validate(_ text: String) -> ValidationResult {
        text.isEmpty ? .invalid(PasswordValidationError.empty) : .valid(text)
    }
}

// MARK: - Composite Validator
// バリデーションに使用する

// メールアドレスのバリデーション
struct EmailValidator: CompositeValidator {
    var validators: [Validator]
    init() {
        self.validators = [
            EmailEmptyValidator(),
            EmailLengthValidator(min: 1, max: 254),
            EmailFormatValidator()
        ]
    }
}

// パスワードのバリデーション
struct PasswordValidator: CompositeValidator {
    var validators: [Validator]
    init() {
        self.validators = [PasswordEmptyValidator()]
    }
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
    case emailFormat        //Email形式
}

//MARK: - 正規表現による文字の判別メソッドの追加
private extension String {
    func isInvalid(textType: TextType) -> Bool {
        switch textType {
            // 全角 (＝１バイトの文字\x01-\x7Eと半角カナ\uFF61-\uFF9F以外)
        case .fullWidth:
            return range(of: "^[^\\x01-\\x7E\\uFF61-\\uFF9F]+$", options: .regularExpression) == nil
            // 全角ひらがな
        case .fullWidthHiragana:
            return range(of: "^[\\u3041-\\u3096F]+$", options: .regularExpression) == nil
            // 全角カタカナ
        case .fullwidthKatakana:
            return range(of: "^[\\u30a1-\\u30f6]+$", options: .regularExpression) == nil
            // 半角英数字
        case .halfWidthAlphanumeric:
            return range(of: "^[a-zA-Z0-9]+$", options: .regularExpression) == nil
            // 半角数字
        case .halfWidthNumeric:
            return range(of: "^[0-9]+$", options: .regularExpression) == nil
            // 半角英字
        case .halfWidthAlphabetic:
            return range(of: "^[a-zA-Z]+$", options: .regularExpression) == nil
            // 半角英字 (大文字)
        case .halfWidthUpperAlphabetic:
            return range(of: "^[A-Z]+$", options: .regularExpression) == nil
            // 半角英字 (小文字)
        case .halfWidthLowerAlphabetic:
            return range(of: "^[a-z]+$", options: .regularExpression) == nil
            // Email
        case .emailFormat:
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
            return !NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
        }
    }
}
