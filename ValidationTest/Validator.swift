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

enum ValidationError: Error {
    case empty
    case length(min: Int, max: Int)
    case halfWidthCharacterFormat
    case fullWidthCharacterFormat
    case phoneNumberFormat

    var description: String {
        switch self {
        case .empty:
            return "文字を入力してください"
        case .length(let min, let max):
            return "文字数を\(min)文字以上、\(max)文字以下で入力してください"
        case .halfWidthCharacterFormat:
            return "全て半角文字で入力してください"
        case .fullWidthCharacterFormat:
            return "全て全角文字で入力してください"
        case .phoneNumberFormat:
            return "20桁以下の値、かつ　全て半角英大文字・半角数字・半角ハイフンで入力してください"
        }
    }
}

//バリデーションに関する役割
protocol Validator {
    func validate(_ text: String) -> ValidationResult
}

//種類ごとにvalidationを持ち、それぞれ実行して結果を返す複合バリデーションの役割
protocol CompositeValidator: Validator {
    var validators: [Validator] { get }
    func validate(_ text: String) -> ValidationResult
}

//複合バリデーター。これを使用してバリデーションを順番にかけていく。
extension CompositeValidator {
    ///validatorsの中のvalidatorの結果を順番に取得して配列として返す
    private func validate(_ text: String) -> [ValidationResult] {
        return validators.map { $0.validate(text) }
    }

    ///これが使うやつ。結果をValidationResultに型付けしてあげる
    func validate(_ text: String) -> ValidationResult {
        let results: [ValidationResult] = validate(text)

        //順番に実行したバリデーションでエラーを吐いたもの(最初のエラー)を返す。なければ.valid
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

//MARK: - 様々なValidatorを作成
//必須項目の入力バリデーション
struct EmptyValidator: Validator {
    func validate(_ text: String) -> ValidationResult {
        if text.isEmpty {
            return .invalid(.empty)
        } else {
            return .valid
        }
    }
}

//min文字以上、max文字以内の文字数制限バリデーション
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

//半角文字かどうかのバリデーション
struct HalfWidthValidator: Validator {
    func validate(_ text: String) -> ValidationResult {
        if text.isHalfWidthCharacter() {
            return .valid
        } else {
            return .invalid(.halfWidthCharacterFormat)
        }
    }
}

//全角文字かどうかのバリデーション
struct FullWidthValidator: Validator {
    func validate(_ text: String) -> ValidationResult {
        if text.isFullWidthCharacter() {
            return .valid
        } else {
            return .invalid(.fullWidthCharacterFormat)
        }
    }
}

//「20桁以下の値、かつ　全て半角英大文字・半角数字・半角ハイフン（"-"）のいずれか」
//例：電話番号
struct PhoneNumberValidator: Validator {
    func validate(_ text: String) -> ValidationResult {
        if text.range(of: "[^A-Z0-9- $]", options: .regularExpression) == nil {
            return .valid
        } else {
            return .invalid(.phoneNumberFormat)
        }
    }
}






//MARK: - 複合Validatorを作成していく
struct NameValidator: CompositeValidator {
//    var validators: [Validator] = [
//        EmptyValidator(),
//        LengthValidator(min: 1, max: 20),
//        HalfWidthValidator()
//    ]
    var validators: [Validator] = [
        HalfWidthValidator()
    ]


}

//MARK: - Extension+
private extension String {
    /// 文字が半角英数字か判定
    /// - Returns: true：半角英数字カナのみ、false：半角以外が含まれる
    func isHalfWidthCharacter() -> Bool {
//        return range(of: "[^a-zA-Z0-9ｦ-゜$]", options: .regularExpression) == nil // TODO: 半濁音記号はどれが正しいか調査必要
        return range(of: "[^a-zA-Z0-9- $]", options: .regularExpression) == nil
    }

    /// 文字が全角文字か判定
    /// - Returns: true：全角英数字カナかな漢字のみ、false：全角以外が含まれる
    func isFullWidthCharacter() -> Bool {
        return (range(of: "[^ａ-ｚＡ-Ｚ０-９ぁ-んァ-ヴ\u{3005}\u{3007}\u{303b}\u{3400}-\u{9fff}\u{f900}-\u{faff}\u{20000}-\u{2ffff}ー　$]", options: .regularExpression) == nil)
    }

}
