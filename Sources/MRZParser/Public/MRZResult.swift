//
//  MRZResult.swift
//  
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Foundation

public enum MRZFormat: CaseIterable {
    case td1, td2, td3

    public var lineLength: Int {
        switch self {
        case .td1:
            return 30
        case .td2:
            return 36
        case .td3:
            return 44
        }
    }

    public var linesCount: Int {
        switch self {
        case .td1:
            return 3
        case .td2, .td3:
            return 2
        }
    }
}

public struct MRZResult: Hashable {
    public enum DocumentType: CaseIterable {
        case visa
        case passport
        case id
        case residencePermit
        case undefined

        var identifiers: [String] {
            switch self {
            case .visa:
                return ["V"]
            case .passport:
                return ["P", "PN"]
            case .id:
                return ["I"]
            case .residencePermit:
                return ["IR"]
            case .undefined:
                return []
            }
        }
    }

    public enum Sex: CaseIterable {
        case male
        case female
        case unspecified

        var identifier: [String] {
            switch self {
            case .male:
                return ["M"]
            case .female:
                return ["F"]
            case .unspecified:
                return ["X", "<", " "]
            }
        }
    }

    public let format: MRZFormat
    public let documentType: DocumentType
    public let countryCode: String
    public let surnames: String
    public let givenNames: String
    public let documentNumber: String?
    public let nationalityCountryCode: String
    public let birthdate: Date?
    public let sex: Sex
    public let expiryDate: Date?
    public let optionalData: String?
    /// `nil` if not provided
    public let optionalData2: String?

    public init(
        format: MRZFormat,
        documentType: DocumentType,
        countryCode: String,
        surnames: String,
        givenNames: String,
        documentNumber: String?,
        nationalityCountryCode: String,
        birthdate: Date?,
        sex: Sex,
        expiryDate: Date?,
        optionalData: String?,
        optionalData2: String?
    ) {
        self.format = format
        self.documentType = documentType
        self.countryCode = countryCode
        self.surnames = surnames
        self.givenNames = givenNames
        self.documentNumber = documentNumber
        self.nationalityCountryCode = nationalityCountryCode
        self.birthdate = birthdate
        self.sex = sex
        self.expiryDate = expiryDate
        self.optionalData = optionalData
        self.optionalData2 = optionalData2
    }
}

