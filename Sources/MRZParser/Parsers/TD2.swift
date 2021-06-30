//
//  TD2.swift
//  QKMRZParser
//
//  Created by Roman Mazeev on 14/10/2018.
//

import Foundation

public class TD2 {
    public static let lineLength = 36
    public static let linesCount = 2

    private let format: MRZResult.MRZFormat
    private let documentTypeField: Field
    private let countryCodeField: Field
    private let namesField: NamesField
    private let documentNumberField: ValidatedField<String>
    private let nationalityField: Field
    private let birthdateField: ValidatedField<Date?>
    private let sexField: Field
    private let expiryDateField: ValidatedField<Date?>
    private let optionalDataField: ValidatedField<String>
    private let finalCheckDigit: String?

    lazy var result: MRZResult? = {
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
            optionalData2: nil
        )
    }()

    private var fieldsIsValid: Bool {
        if let checkDigit = finalCheckDigit {
            let fieldsValidate: [ValidatedFieldProtocol] = [
                documentNumberField,
                birthdateField,
                expiryDateField,
                optionalDataField
            ]
            let compositedValue = fieldsValidate.reduce("", { $0 + $1.rawValue + $1.checkDigit })
            let isCompositedValueValid = MRZFieldFormatter.isValueValid(compositedValue, checkDigit: checkDigit)
            return documentNumberField.isValid &&
                    birthdateField.isValid &&
                    expiryDateField.isValid &&
                    isCompositedValueValid
        } else {
            return documentNumberField.isValid &&
                    birthdateField.isValid &&
                    expiryDateField.isValid
        }
    }

    init(from mrzLines: [String], using formatter: MRZFieldFormatter) {
        let (firstLine, secondLine) = (mrzLines[0], mrzLines[1])
        /// MRV-B type
        let isVisaDocument = (firstLine.substring(0, to: 0) == "V")
        format = isVisaDocument ? .mrvb : .td2

        documentTypeField = formatter.createField(from: firstLine, at: 0, length: 2)
        countryCodeField = formatter.createField(from: firstLine, at: 2, length: 3)
        namesField = formatter.createNamesField(from: firstLine, at: 5, length: 31)

        documentNumberField = formatter.createStringValidatedField(from: secondLine, at: 0, length: 9)
        nationalityField = formatter.createField(from: secondLine, at: 10, length: 3)
        birthdateField = formatter.createDateValidatedField(from: secondLine, at: 13, length: 6, isBirthDate: true)
        sexField = formatter.createField(from: secondLine, at: 20, length: 1)
        expiryDateField = formatter.createDateValidatedField(from: secondLine, at: 21, length: 6, isBirthDate: false)
        optionalDataField = formatter.createStringValidatedField(
            from: secondLine,
            at: 28,
            length: isVisaDocument ? 8 : 7,
            checkDigitFollows: false
        )
        finalCheckDigit = isVisaDocument ? nil : formatter.createField(
            from: secondLine, at: 35, length: 1
        ).rawValue
    }
}
