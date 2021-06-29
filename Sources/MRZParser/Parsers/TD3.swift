//
//  TD3.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 14/10/2018.
//

import Foundation

//Params:                      Case insensitive
//
//    document_type    (str):  Normally 'P' for passport
//    country_code     (str):  3 letters code (ISO 3166-1) or country name (in English)
//    surname          (str):  Primary identifier(s)
//    given_names      (str):  Secondary identifier(s)
//    document_number  (str):  Document number
//    nationality      (str):  3 letters code (ISO 3166-1) or country name
//    birth_date       (str):  YYMMDD
//    sex              (str):  Genre. Male: 'M', Female: 'F' or Undefined: 'X', "<" or ""
//    expiry_date      (str):  YYMMDD
//    optional data    (str):  Personal number. In some countries non-mandatory field. Empty string by default
//    transliteration (dict):  Transliteration dictionary for non-ascii chars. Latin based by default
//    force           (bool):  Disables checks for country, nationality and document_type fields.
//                             Allows to use 3-letter-codes not included in the countries dictionary
//                             and to use document_type codes without restrictions.

public class TD3 {
    public static let lineLength = 44
    public static let linesCount = 2
    static func isLineValid(line: String) -> Bool {
        // TODO: Line validation
        return true
    }

    private let finalCheckDigit: String?
    private let documentType: MRZField
    private let countryCode: MRZField
    private let names: MRZField
    private let documentNumber: MRZField
    private let nationality: MRZField
    private let birthdate: MRZField
    private let sex: MRZField
    private let expiryDate: MRZField
    private let personalNumber: MRZField
    
    private lazy var allCheckDigitsValid: Bool = {
        if let checkDigit = finalCheckDigit {
            let compositedValue = [documentNumber, birthdate, expiryDate, personalNumber].reduce("", { ($0 + $1.rawValue + $1.checkDigit!) })
            let isCompositedValueValid = MRZField.isValueValid(compositedValue, checkDigit: checkDigit)
            return (documentNumber.isValid! && birthdate.isValid! && expiryDate.isValid! && personalNumber.isValid! && isCompositedValueValid)
        }
        else {
            return (documentNumber.isValid! && birthdate.isValid! && expiryDate.isValid!)
        }
    }()
    
    lazy var result: MRZResult = {
        let (surnames, givenNames) = names.value as! (String, String)
        
        return MRZResult(
            documentType: documentType.value as! String,
            countryCode: countryCode.value as! String,
            surnames: surnames,
            givenNames: givenNames,
            documentNumber: documentNumber.value as! String,
            nationalityCountryCode: nationality.value as! String,
            birthdate: birthdate.value as! Date?,
            sex: sex.value as! String?,
            expiryDate: expiryDate.value as! Date?,
            personalNumber: personalNumber.value as! String,
            personalNumber2: nil,
            
            isDocumentNumberValid: documentNumber.isValid!,
            isBirthdateValid: birthdate.isValid!,
            isExpiryDateValid: expiryDate.isValid!,
            isPersonalNumberValid: personalNumber.isValid,
            allCheckDigitsValid: allCheckDigitsValid
        )
    }()
    
    init(from mrzLines: [String], using formatter: MRZFieldFormatter) {
        let (firstLine, secondLine) = (mrzLines[0], mrzLines[1])

        /// MRV-A type
        let isVisaDocument = (firstLine.substring(0, to: 0) == "V")
        
        documentType = formatter.createField(type: .documentType, from: firstLine, at: 0, length: 2)
        countryCode = formatter.createField(type: .countryCode, from: firstLine, at: 2, length: 3)
        names = formatter.createField(type: .names, from: firstLine, at: 5, length: 39)
        
        documentNumber = formatter.createField(type: .documentNumber, from: secondLine, at: 0, length: 9, checkDigitFollows: true)
        nationality = formatter.createField(type: .nationality, from: secondLine, at: 10, length: 3)
        birthdate = formatter.createField(type: .birthdate, from: secondLine, at: 13, length: 6, checkDigitFollows: true)
        sex = formatter.createField(type: .sex, from: secondLine, at: 20, length: 1)
        expiryDate = formatter.createField(type: .expiryDate, from: secondLine, at: 21, length: 6, checkDigitFollows: true)
        
        if isVisaDocument {
            personalNumber = formatter.createField(type: .optionalData, from: secondLine, at: 28, length: 16)
            finalCheckDigit = nil
        }
        else {
            personalNumber = formatter.createField(type: .personalNumber, from: secondLine, at: 28, length: 14, checkDigitFollows: true)
            finalCheckDigit = formatter.createField(type: .hash, from: secondLine, at: 43, length: 1).rawValue
        }
    }
}
