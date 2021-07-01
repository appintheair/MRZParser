//
//  MRZResult.swift
//  
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Foundation

public struct MRZResult: Hashable {
    public enum MRZFormat {
        case td1, td2, td3, mrva, mrvb
    }

    public enum DocumentType: CaseIterable {
        case visa
        case passport
        case id
        case undefined

        var identifier: String {
            switch self {
            case .visa:
                return "V"
            case .passport:
                return "P"
            case .id:
                return "I"
            case .undefined:
                return ""
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
}

