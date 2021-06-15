//
//  MRZResult.swift
//  
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Foundation

public struct MRZResult {
    public let documentType: String
    public let countryCode: String
    public let surnames: String
    public let givenNames: String
    public let documentNumber: String
    public let nationalityCountryCode: String
    /// `nil` if formatting failed
    public let birthdate: Date?
    /// `nil` if formatting failed
    public let sex: String?
    /// `nil` if formatting failed
    public let expiryDate: Date?
    public let personalNumber: String
    /// `nil` if not provided
    public let personalNumber2: String?

    public let isDocumentNumberValid: Bool
    public let isBirthdateValid: Bool
    public let isExpiryDateValid: Bool
    public let isPersonalNumberValid: Bool?
    public let allCheckDigitsValid: Bool
}

