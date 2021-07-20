//
//  MRZCode.swift
//
//
//  Created by Roman Mazeev on 20.07.2021.
//

import Foundation

struct MRZCode {
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
    var finalCheckDigit: String?

    var isValid: Bool {
        if let finalCheckDigit = finalCheckDigit {
            var fieldsValidate: [ValidatedFieldProtocol] = [
                documentNumberField,
                birthdateField,
                expiryDateField,
                optionalDataField
            ]

            if let optionalData2Field = optionalData2Field {
                fieldsValidate.append(optionalData2Field)
            }

            let compositedValue = fieldsValidate
                .filter { $0.isValid }
                .reduce("", { $0 + $1.rawValue + $1.checkDigit })
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
