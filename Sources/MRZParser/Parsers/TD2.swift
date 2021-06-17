//
//  TD2.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 14/10/2018.
//

import Foundation

public class TD2 {
    public static let lineLength = 36
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
    private let optionalData: MRZField
    
    private lazy var allCheckDigitsValid: Bool = {
        if let checkDigit = finalCheckDigit {
            let compositedValue = [documentNumber, birthdate, expiryDate, optionalData].reduce("", { ($0 + $1.rawValue + ($1.checkDigit ?? "")) })
            let isCompositedValueValid = MRZField.isValueValid(compositedValue, checkDigit: checkDigit)
            return (documentNumber.isValid! && birthdate.isValid! && expiryDate.isValid! && isCompositedValueValid)
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
            personalNumber: optionalData.value as! String,
            personalNumber2: nil,
            
            isDocumentNumberValid: documentNumber.isValid!,
            isBirthdateValid: birthdate.isValid!,
            isExpiryDateValid: expiryDate.isValid!,
            isPersonalNumberValid: nil,
            allCheckDigitsValid: allCheckDigitsValid
        )
    }()

    init(from mrzLines: [String], using formatter: MRZFieldFormatter) {
        let (firstLine, secondLine) = (mrzLines[0], mrzLines[1])
        /// MRV-B type
        let isVisaDocument = (firstLine.substring(0, to: 0) == "V")
        
        documentType = formatter.createField(type: .documentType, from: firstLine, at: 0, length: 2)
        countryCode = formatter.createField(type: .countryCode, from: firstLine, at: 2, length: 3)
        names = formatter.createField(type: .names, from: firstLine, at: 5, length: 31)
        
        documentNumber = formatter.createField(type: .documentNumber, from: secondLine, at: 0, length: 9, checkDigitFollows: true)
        nationality = formatter.createField(type: .nationality, from: secondLine, at: 10, length: 3)
        birthdate = formatter.createField(type: .birthdate, from: secondLine, at: 13, length: 6, checkDigitFollows: true)
        sex = formatter.createField(type: .sex, from: secondLine, at: 20, length: 1)
        expiryDate = formatter.createField(type: .expiryDate, from: secondLine, at: 21, length: 6, checkDigitFollows: true)
        optionalData = formatter.createField(type: .optionalData, from: secondLine, at: 28, length: isVisaDocument ? 8 : 7)
        finalCheckDigit = isVisaDocument ? nil : formatter.createField(type: .hash, from: secondLine, at: 35, length: 1).rawValue
    }
}
