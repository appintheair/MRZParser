//
//  TD3.swift
//  QKMRZParser
//
//  Created by Roman Mazeev on 14/10/2018.
//

import Foundation

public class TD3 {
    public static let lineLength = 44
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
        guard fieldsIsValid else { return nil }

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
            let fieldsToValidate: [ValidatedFieldProtocol] = [
                documentNumberField,
                birthdateField,
                expiryDateField,
                optionalDataField
            ]

            let compositedValue = fieldsToValidate.reduce("", {
                ($0 + $1.rawValue + $1.checkDigit)
            })
            let isCompositedValueValid = MRZFieldFormatter.isValueValid(compositedValue, checkDigit: checkDigit)
            return documentNumberField.isValid &&
                    birthdateField.isValid &&
                    expiryDateField.isValid &&
                    optionalDataField.isValid &&
                    isCompositedValueValid
        } else {
            return documentNumberField.isValid &&
                    birthdateField.isValid &&
                    expiryDateField.isValid
        }
    }
    
    init(from mrzLines: [String], using formatter: MRZFieldFormatter) {
        let (firstLine, secondLine) = (mrzLines[0], mrzLines[1])

        /// MRV-A type
        let isVisaDocument = (firstLine.substring(0, to: 0) == "V")
        format = isVisaDocument ? .mrva : .td3
        
        documentTypeField = formatter.createField(from: firstLine, at: 0, length: 2, fieldType: .documentType)
        countryCodeField = formatter.createField(from: firstLine, at: 2, length: 3, fieldType: .countryCode)
        namesField = formatter.createNamesField(from: firstLine, at: 5, length: 39)
        
        documentNumberField = formatter.createStringValidatedField(
            from: secondLine,
            at: 0,
            length: 9,
            fieldType: .documentNumber
        )
        nationalityField = formatter.createField(from: secondLine, at: 10, length: 3, fieldType: .nationality)
        birthdateField = formatter.createDateValidatedField(from: secondLine, at: 13, length: 6, fieldType: .birthdate)
        sexField = formatter.createField(from: secondLine, at: 20, length: 1, fieldType: .sex)
        expiryDateField = formatter.createDateValidatedField(
            from: secondLine, at: 21, length: 6, fieldType: .expiryDate
        )
        
        if isVisaDocument {
            optionalDataField = formatter.createStringValidatedField(
                from: secondLine,
                at: 28,
                length: 16,
                fieldType: .optionalData,
                checkDigitFollows: false
            )
            finalCheckDigit = nil
        } else {
            optionalDataField = formatter.createStringValidatedField(
                from: secondLine, at: 28, length: 14, fieldType: .optionalData
            )
            finalCheckDigit = formatter.createField(from: secondLine, at: 43, length: 1, fieldType: .hash).rawValue
        }
    }
}
