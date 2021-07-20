//
//  MRZFieldFormatter.swift
//  
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Foundation

struct MRZFieldFormatter {
    private let isOCRCorrectionEnabled: Bool
    private let ocrCorrector = OCRCorrector()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        return formatter
    }()

    init(isOCRCorrectionEnabled: Bool) {
        self.isOCRCorrectionEnabled = isOCRCorrectionEnabled
    }

    func createField(
        from string: String,
        at startIndex: Int,
        length: Int,
        fieldType: MRZFieldType
    ) -> Field {
        let rawValue = getRawValue(from: string, startIndex: startIndex, length: length, fieldType: fieldType)
        return Field(value: text(from: rawValue), rawValue: rawValue)
    }

    func createNamesField(
        from string: String,
        at startIndex: Int,
        length: Int
    ) -> NamesField {
        let rawValue = getRawValue(from: string, startIndex: startIndex, length: length, fieldType: .names)
        return names(from: rawValue)
    }

    enum DateValidatedFieldType {
        case birthdate
        case expiryDate

        var mrzFieldType: MRZFieldType {
            switch self {
            case .birthdate:
                return MRZFieldType.birthdate
            case .expiryDate:
                return MRZFieldType.expiryDate
            }
        }
    }

    func createDateValidatedField(
        from string: String,
        at startIndex: Int,
        length: Int,
        fieldType: DateValidatedFieldType
    ) -> ValidatedField<Date?> {
        let rawValue = getRawValue(from: string, startIndex: startIndex, length: length, fieldType: fieldType.mrzFieldType)
        let checkDigit = getCheckDigit(from: string, endIndex: startIndex + length, fieldType: fieldType.mrzFieldType)

        let value: Date?
        switch fieldType {
        case .birthdate:
            value = birthdate(from: rawValue)
        case .expiryDate:
            value = expiryDate(from: rawValue)
        }

        return ValidatedField(value: value, rawValue: rawValue, checkDigit: checkDigit)
    }

    func createStringValidatedField(
        from string: String,
        at startIndex: Int,
        length: Int,
        fieldType: MRZFieldType,
        checkDigitFollows: Bool = true
    ) -> ValidatedField<String> {
        let rawValue = getRawValue(
            from: string,
            startIndex: startIndex,
            length: length,
            fieldType: fieldType
        )
        let checkDigit = checkDigitFollows ? getCheckDigit(
            from: string,
            endIndex: startIndex + length,
            fieldType: fieldType
        ) : ""

        return ValidatedField(value: text(from: rawValue), rawValue: rawValue, checkDigit: checkDigit)
    }

    private func getRawValue(
        from string: String,
        startIndex: Int,
        length: Int,
        fieldType: MRZFieldType
    ) -> String {
        let endIndex = startIndex + length
        var value = string.substring(startIndex, to: (endIndex - 1))

        if isOCRCorrectionEnabled {
            value = ocrCorrector.correct(value, fieldType: fieldType)
        }

        return value
    }

    private func getCheckDigit(
        from string: String,
        endIndex: Int,
        fieldType: MRZFieldType
    ) -> String {
        var value = string.substring(endIndex, to: endIndex)

        if isOCRCorrectionEnabled {
            value = ocrCorrector.correct(value, fieldType: fieldType)
        }

        return value
    }

    private func names(from string: String) -> NamesField {
        let identifiers = string.trimmingFillers.components(separatedBy: "<<").map { $0.replace("<", with: " ") }
        var secondaryID: String?

        if identifiers.indices.contains(1) {
            secondaryID = identifiers[1]
        }

        return (surnames: identifiers.first ?? "", givenNames: secondaryID ?? "")
    }

    private func birthdate(from string: String) -> Date? {
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)),
              let parsedYear = Int(string.substring(0, to: 1)) else { return nil }
        let currentYear = Calendar.current.component(.year, from: Date()) - 2000
        let centennial = (parsedYear > currentYear) ? "19" : "20"
        return dateFormatter.date(from: centennial + string)
    }

    private func expiryDate(from string: String) -> Date? {
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)),
              let parsedYear = Int(string.substring(0, to: 1)) else { return nil }
        let centennial = (parsedYear >= 70) ? "19" : "20"
        return dateFormatter.date(from: centennial + string)
    }

    private func text(from string: String) -> String {
        string.trimmingFillers.replace("<", with: " ")
    }

    static func isValueValid(_ rawValue: String, checkDigit: String) -> Bool {
        guard let numericCheckDigit = Int(checkDigit) else {
            return checkDigit == "<" ? rawValue.trimmingFillers.isEmpty : false
        }

        var total = 0

        for (index, character) in rawValue.enumerated() {
            guard let unicodeScalar = character.unicodeScalars.first else { return false }
            let charValue: Int

            if CharacterSet.uppercaseLetters.contains(unicodeScalar) {
                charValue = Int(10 + unicodeScalar.value) - 65
            } else if CharacterSet.decimalDigits.contains(unicodeScalar), let digit = Int(String(character)) {
                charValue = digit
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
