//
//  MRZFieldFormatter.swift
//  
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Foundation

struct MRZFieldFormatter {
    private static let currentCentennial = Calendar.current.component(.year, from: Date()) / 100
    private static let previousCentennial = Self.currentCentennial - 1

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
        let currentYear = Calendar.current.component(.year, from: Date()) - Self.currentCentennial * 100
        let centennial = (parsedYear > currentYear) ? String(Self.previousCentennial) : String(Self.currentCentennial)
        return dateFormatter.date(from: centennial + string)
    }

    private func expiryDate(from string: String) -> Date? {
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)),
              let parsedYear = Int(string.substring(0, to: 1)) else { return nil }
        let currentYear = Calendar.current.component(.year, from: Date()) - Self.currentCentennial * 100
        let boundaryYear = currentYear + 50
        let centennial = parsedYear >= boundaryYear ? String(Self.previousCentennial) : String(Self.currentCentennial)
        return dateFormatter.date(from: centennial + string)
    }

    private func text(from string: String) -> String {
        string.trimmingFillers.replace("<", with: " ")
    }

    static func isValueValid(_ rawValue: String, checkDigit: String) -> Bool {
        guard let numericCheckDigit = Int(checkDigit) else {
            return checkDigit == "<" ? rawValue.trimmingFillers.isEmpty : false
        }

        return Self.checkDigit(for: rawValue) == numericCheckDigit
    }

    static func checkDigit(for value: String) -> Int? {
        var sum: Int = 0
        for (index, character) in value.enumerated() {
            guard let number = number(for: character) else { return nil }
            let weights = [7, 3, 1]
            sum += number * weights[index % 3]
        }
        return sum % 10
    }

    // <  A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z
    // 0  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35
    private static func number(for character: Character) -> Int? {
        guard let unicodeScalar = character.unicodeScalars.first else { return nil }
        let number: Int
        if CharacterSet.uppercaseLetters.contains(unicodeScalar) {
            number = Int(10 + unicodeScalar.value) - 65
        } else if CharacterSet.decimalDigits.contains(unicodeScalar), let digit = character.wholeNumberValue {
            number = digit
        } else if character == "<" {
            number = 0
        } else {
            return nil
        }
        return number
    }
}
