//
//  TD1.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 14/10/2018.
//

import Foundation

class TD1 {
    static let lineLength = 30
    private let finalCheckDigit: String
    private let documentType: MRZField
    private let countryCode: MRZField
    private let documentNumber: MRZField
    private let optionalData: MRZField
    private let birthdate: MRZField
    private let sex: MRZField
    private let expiryDate: MRZField
    private let nationality: MRZField
    private let optionalData2: MRZField
    private let names: MRZField

    private lazy var allCheckDigitsValid: Bool = {
        let compositedValue = [documentNumber, optionalData, birthdate, expiryDate, optionalData2].reduce("", { ($0 + $1.rawValue + ($1.checkDigit ?? "")) })
        let isCompositedValueValid = MRZField.isValueValid(compositedValue, checkDigit: finalCheckDigit)
        return (documentNumber.isValid! && birthdate.isValid! && expiryDate.isValid! && isCompositedValueValid)
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
            personalNumber2: (optionalData2.value as! String),
            
            isDocumentNumberValid: documentNumber.isValid!,
            isBirthdateValid: birthdate.isValid!,
            isExpiryDateValid: expiryDate.isValid!,
            isPersonalNumberValid: nil,
            allCheckDigitsValid: allCheckDigitsValid
        )
    }()
    
    init(from mrzLines: [String], using formatter: MRZFieldFormatter) {
        let (firstLine, secondLine, thirdLine) = (mrzLines[0], mrzLines[1], mrzLines[2])
        
        documentType = formatter.createField(type: .documentType, from: firstLine, at: 0, length: 2)
        countryCode = formatter.createField(type: .countryCode, from: firstLine, at: 2, length: 3)
        documentNumber = formatter.createField(type: .documentNumber, from: firstLine, at: 5, length: 9, checkDigitFollows: true)
        optionalData = formatter.createField(type: .optionalData, from: firstLine, at: 15, length: 15)
        
        birthdate = formatter.createField(type: .birthdate, from: secondLine, at: 0, length: 6, checkDigitFollows: true)
        sex = formatter.createField(type: .sex, from: secondLine, at: 7, length: 1)
        expiryDate = formatter.createField(type: .expiryDate, from: secondLine, at: 8, length: 6, checkDigitFollows: true)
        nationality = formatter.createField(type: .nationality, from: secondLine, at: 15, length: 3)
        optionalData2 = formatter.createField(type: .optionalData, from: secondLine, at: 18, length: 11)
        finalCheckDigit = formatter.createField(type: .hash, from: secondLine, at: 29, length: 1).rawValue
        
        names = formatter.createField(type: .names, from: thirdLine, at: 0, length: 29)
    }
}
