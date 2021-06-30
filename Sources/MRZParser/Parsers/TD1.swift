//
//  TD1.swift
//  QKMRZParser
//
//  Created by Roman Mazeev on 14/10/2018.
//

import Foundation

public class TD1 {
    public static let lineLength = 30
    public static let linesCount = 3

    private let format: MRZResult.MRZFormat
    private let documentTypeField: Field
    private let countryCodeField: Field
    private let documentNumberField: ValidatedField<String>
    private let birthdateField: ValidatedField<Date>?
    private let sexField: Field
    private let expiryDateField: ValidatedField<Date>?
    private let nationalityField: Field
    private let optionalDataField: ValidatedField<String>
    private let optionalData2Field: ValidatedField<String>
    private let namesField: NamesField
    private let finalCheckDigit: String
    
    lazy var result: MRZResult? = {
        guard fieldsIsValid, let birthdateField = birthdateField, let expiryDateField = expiryDateField else {
            return nil
        }

        return MRZResult(
            format: format,
            documentType: MRZResult.DocumentType.allCases.first(
                where: { $0.identifier.contains(documentTypeField.value) }
            ) ?? .undefined,
            countryCode: countryCodeField.value,
            surnames: namesField.surnames,
            givenNames: namesField.givenNames,
            documentNumber: documentNumberField.value,
            nationalityCountryCode: nationalityField.value,
            birthdate: birthdateField.value,
            sex: MRZResult.Sex.allCases.first(where: { $0.identifier.contains(sexField.value) }) ?? .unspecified,
            expiryDate: expiryDateField.value,
            optionalData: optionalDataField.value,
            optionalData2: optionalData2Field.value
        )
    }()

    private var fieldsIsValid: Bool {
        guard let birthdateField = birthdateField, let expiryDateField = expiryDateField else { return false }
        let filedsToValidate: [ValidatedFieldProtocol] = [
            documentNumberField,
            birthdateField,
            expiryDateField,
            optionalDataField,
            optionalData2Field
        ]
        let compositedValue = filedsToValidate.reduce("", { $0 + $1.rawValue + $1.checkDigit })
        let isCompositedValueValid = MRZFieldFormatter.isValueValid(compositedValue, checkDigit: finalCheckDigit)
        return documentNumberField.isValid && birthdateField.isValid && expiryDateField.isValid &&
        isCompositedValueValid
    }
    
    init(from mrzLines: [String], using formatter: MRZFieldFormatter) {
        let (firstLine, secondLine, thirdLine) = (mrzLines[0], mrzLines[1], mrzLines[2])
        format = .td1

        documentTypeField = formatter.createField(from: firstLine, at: 0, length: 2)
        countryCodeField = formatter.createField(from: firstLine, at: 2, length: 3)
        documentNumberField = formatter.createStringValidatedField(from: firstLine, at: 5, length: 9)
        optionalDataField = formatter.createStringValidatedField(
            from: firstLine,
            at: 15,
            length: 15,
            checkDigitFollows: false
        )
        birthdateField = formatter.createDateValidatedField(from: secondLine, at: 0, length: 6, isBirthDate: true)
        sexField = formatter.createField(from: secondLine, at: 7, length: 1)
        expiryDateField = formatter.createDateValidatedField(from: secondLine, at: 8, length: 6, isBirthDate: false)
        nationalityField = formatter.createField(from: secondLine, at: 15, length: 3)
        optionalData2Field = formatter.createStringValidatedField(
            from: secondLine,
            at: 18,
            length: 11,
            checkDigitFollows: false
        )
        finalCheckDigit = formatter.createField(from: secondLine, at: 29, length: 1).rawValue
        namesField = formatter.createNamesField(from: thirdLine, at: 0, length: 29)
    }
}
