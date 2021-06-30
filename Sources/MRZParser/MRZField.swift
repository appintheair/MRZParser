//
//  MRZField.swift
//  
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Foundation

typealias NamesField = (surnames: String, givenNames: String)

struct Field {
    let value: String
    let rawValue: String
}

protocol ValidatedField {
    var rawValue: String { get }
    var checkDigit: String { get }
    var isValid: Bool { get }
}

extension ValidatedField {
    var isValid: Bool {
        return MRZFieldFormatter.isValueValid(rawValue, checkDigit: checkDigit)
    }
}

struct StringValidatedField: ValidatedField {
    let value: String
    let rawValue: String
    let checkDigit: String
}

struct DateValidatedField: ValidatedField {
    let value: Date
    let rawValue: String
    let checkDigit: String
}
