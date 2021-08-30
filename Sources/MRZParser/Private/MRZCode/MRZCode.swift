//
//  MRZCode.swift
//
//
//  Created by Roman Mazeev on 20.07.2021.
//

import Foundation

struct MRZCode {
    let format: MRZFormat
    var documentTypeField: Field
    var countryCodeField: Field
    var documentNumberField: ValidatedField<String>
    var birthdateField: ValidatedField<Date?>
    var sexField: Field
    var expiryDateField: ValidatedField<Date?>
    var nationalityField: Field
    var optionalDataField: ValidatedField<String>
    var optionalData2Field: ValidatedField<String>?
    var namesField: NamesField
    var finalCheckDigit: String

    var isValid: Bool {
        if !finalCheckDigit.isEmpty {
            var fieldsValidate: [ValidatedFieldProtocol] = [ documentNumberField ]

            if format == .td1, let optionalData2Field = optionalData2Field {
                fieldsValidate.append(optionalDataField)
                fieldsValidate.append(contentsOf: [
                    birthdateField,
                    expiryDateField
                ])
                fieldsValidate.append(optionalData2Field)
            } else {
                fieldsValidate.append(contentsOf: [
                    birthdateField,
                    expiryDateField
                ])

                fieldsValidate.append(optionalDataField)
            }

            let compositedValue = fieldsValidate.reduce("", { $0 + $1.rawValue + $1.checkDigit })
            let isCompositedValueValid = MRZFieldFormatter.isValueValid(compositedValue, checkDigit: finalCheckDigit)
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
}
