//
//  MRZField.swift
//  
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Foundation

struct MRZField {
    enum FieldType {
        case documentType, countryCode, names, documentNumber, nationality, birthdate, sex, expiryDate, personalNumber, optionalData, hash
    }

    let value: Any?
    let rawValue: String
    let checkDigit: String?
    let isValid: Bool?

    init(value: Any?, rawValue: String, checkDigit: String?) {
        self.value = value
        self.rawValue = rawValue
        self.checkDigit = checkDigit
        self.isValid = (checkDigit == nil) ? nil : MRZField.isValueValid(rawValue, checkDigit: checkDigit!)
    }

    // MARK: Static
    static func isValueValid(_ value: String, checkDigit: String) -> Bool {
        guard let numericCheckDigit = Int(checkDigit) else {
            return checkDigit == "<" ? value.trimmingFillers.isEmpty : false
        }

        var total = 0

        for (index, character) in value.enumerated() {
            guard let unicodeScalar = character.unicodeScalars.first else { return false }
            let charValue: Int

            if CharacterSet.uppercaseLetters.contains(unicodeScalar) {
                charValue = Int(10 + unicodeScalar.value) - 65
            } else if CharacterSet.decimalDigits.contains(unicodeScalar) {
                charValue = Int(String(character))!
            } else if character == "<" {
                charValue = 0
            } else {
                return false
            }

            total += charValue * [7, 3, 1][index % 3]
        }

        return total % 10 == numericCheckDigit
    }
}


