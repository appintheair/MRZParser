//
//  MRZField.swift
//  
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Foundation

// MARK: - BasicFields
typealias NamesField = (surnames: String, givenNames: String)

struct Field {
    let value: String
    let rawValue: String
}

// MARK: - ValidatedField
protocol ValidatedFieldProtocol {
    var rawValue: String { get }
    var checkDigit: String { get }
    var isValid: Bool { get }
}

extension ValidatedFieldProtocol {
    var isValid: Bool {
        return MRZFieldFormatter.isValueValid(rawValue, checkDigit: checkDigit)
    }
}

struct ValidatedField<T>: ValidatedFieldProtocol {
    let value: T?
    let rawValue: String
    let checkDigit: String
}
