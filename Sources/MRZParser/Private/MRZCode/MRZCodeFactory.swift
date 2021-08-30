//
//  MRZCodeFactory.swift
//
//
//  Created by Roman Mazeev on 14/10/2018.
//

import Foundation

struct MRZCodeFactory {
    func create(
        from mrzLines: [String],
        format: MRZFormat,
        formatter: MRZFieldFormatter
    ) -> MRZCode {
        let (firstLine, secondLine) = (mrzLines[0], mrzLines[1])

        let documentNumberField: ValidatedField<String>
        let birthdateField: ValidatedField<Date?>
        let sexField: Field
        let expiryDateField: ValidatedField<Date?>
        let nationalityField: Field
        let optionalDataField: ValidatedField<String>
        let optionalData2Field: ValidatedField<String>?
        let namesField: NamesField
        let finalCheckDigit: String

        switch format {
        case .td1:
            documentNumberField = formatter.createStringValidatedField(
                from: firstLine,
                at: 5,
                length: 9,
                fieldType: .documentNumber
            )
            birthdateField = formatter.createDateValidatedField(
                from: secondLine,
                at: 0,
                length: 6,
                fieldType: .birthdate
            )
            sexField = formatter.createField(from: secondLine, at: 7, length: 1, fieldType: .sex)
            expiryDateField = formatter.createDateValidatedField(
                from: secondLine,
                at: 8,
                length: 6,
                fieldType: .expiryDate
            )
            nationalityField = formatter.createField(from: secondLine, at: 15, length: 3, fieldType: .nationality)
            optionalDataField = formatter.createStringValidatedField(
                from: firstLine,
                at: 15,
                length: 15,
                fieldType: .optionalData,
                checkDigitFollows: false
            )
            optionalData2Field = formatter.createStringValidatedField(
                from: secondLine,
                at: 18,
                length: 11,
                fieldType: .optionalData,
                checkDigitFollows: false
            )
            finalCheckDigit = formatter.createField(from: secondLine, at: 29, length: 1, fieldType: .hash).rawValue

            let thirdLine = mrzLines[2]
            namesField = formatter.createNamesField(from: thirdLine, at: 0, length: 29)
        case .td2, .td3:
            /// MRV-B and MRV-A types
            let isVisaDocument =  MRZResult.DocumentType.visa.identifiers.contains(firstLine.substring(0, to: 0))

            documentNumberField = formatter.createStringValidatedField(from: secondLine, at: 0, length: 9, fieldType: .documentNumber
            )
            birthdateField = formatter.createDateValidatedField(
                from: secondLine,
                at: 13,
                length: 6,
                fieldType: .birthdate
            )
            sexField = formatter.createField(from: secondLine, at: 20, length: 1, fieldType: .sex)
            expiryDateField = formatter.createDateValidatedField(
                from: secondLine, at: 21, length: 6, fieldType: .expiryDate
            )
            nationalityField = formatter.createField(from: secondLine, at: 10, length: 3, fieldType: .nationality)

            if format == .td2 {
                optionalDataField = formatter.createStringValidatedField(
                    from: secondLine,
                    at: 28,
                    length: isVisaDocument ? 8 : 7,
                    fieldType: .optionalData,
                    checkDigitFollows: false
                )
                optionalData2Field = nil
                namesField = formatter.createNamesField(from: firstLine, at: 5, length: 31)
                finalCheckDigit = isVisaDocument ? "" : formatter.createField(
                    from: secondLine, at: 35, length: 1, fieldType: .hash
                ).rawValue
            } else {
                optionalDataField = {
                    if isVisaDocument {
                        return formatter.createStringValidatedField(
                            from: secondLine,
                            at: 28,
                            length: 16,
                            fieldType: .optionalData,
                            checkDigitFollows: false
                        )
                    } else {
                        return formatter.createStringValidatedField(
                            from: secondLine, at: 28, length: 14, fieldType: .optionalData
                        )
                    }
                }()
                optionalData2Field = nil
                namesField = formatter.createNamesField(from: firstLine, at: 5, length: 39)
                finalCheckDigit = isVisaDocument ? "" : formatter.createField(
                    from: secondLine,
                    at: 43,
                    length: 1,
                    fieldType: .hash
                ).rawValue
            }
        }

        return MRZCode(
            format: format,
            documentTypeField: formatter.createField(from: firstLine, at: 0, length: 2, fieldType: .documentType),
            countryCodeField: formatter.createField(from: firstLine, at: 2, length: 3, fieldType: .countryCode),
            documentNumberField: documentNumberField,
            birthdateField: birthdateField,
            sexField: sexField,
            expiryDateField: expiryDateField,
            nationalityField: nationalityField,
            optionalDataField: optionalDataField,
            optionalData2Field: optionalData2Field,
            namesField: namesField,
            finalCheckDigit: finalCheckDigit
        )
    }
}
