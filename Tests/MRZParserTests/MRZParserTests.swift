//
//  MRZParserTests.swift
//
//
//  Created by Roman Mazeev on 15.06.2021.
//

import XCTest
@testable import MRZParser

final class MRZParserTests: XCTestCase {
    private var parser: MRZParser!

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        return formatter
    }()

    override func setUp() {
        super.setUp()
        parser = MRZParser(isOCRCorrectionEnabled: true)
    }

    func testTD1() {
        let mrzString = """
                        I<UTOD231458907<<<<<<<<<<<<<<<
                        7408122F1204159UTO<<<<<<<<<<<6
                        ERIKSSON<<ANNA<MARIA<<<<<<<<<<
                        """
        let result = MRZResult(
            format: .td1,
            documentType: .id,
            documentTypeAdditional: nil,
            countryCode: "UTO",
            surnames: "ERIKSSON",
            givenNames: "ANNA MARIA",
            documentNumber: "D23145890",
            nationalityCountryCode: "UTO",
            birthdate:  dateFormatter.date(from: "740812")!,
            sex: .female,
            expiryDate: dateFormatter.date(from: "120415")!,
            optionalData: "",
            optionalData2: ""
        )

        XCTAssertEqual(parser.parse(mrzString: mrzString), result)
    }

    func testTD2() {
        let mrzString = """
                        IRUTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<
                        D231458907UTO7408122F1204159<<<<<<<6
                        """
        let result = MRZResult(
            format: .td2,
            documentType: .id,
            documentTypeAdditional: "R",
            countryCode: "UTO",
            surnames: "ERIKSSON",
            givenNames: "ANNA MARIA",
            documentNumber: "D23145890",
            nationalityCountryCode: "UTO",
            birthdate:  dateFormatter.date(from: "740812")!,
            sex: .female,
            expiryDate: dateFormatter.date(from: "120415")!,
            optionalData: "",
            optionalData2: nil
        )

        XCTAssertEqual(parser.parse(mrzString: mrzString), result)
    }

    func testTD3() {
        let mrzString = """
                        P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<
                        L898902C36UTO7408122F1204159ZE184226B<<<<<10
                        """
        let result = MRZResult(
            format: .td3,
            documentType: .passport,
            documentTypeAdditional: nil,
            countryCode: "UTO",
            surnames: "ERIKSSON",
            givenNames: "ANNA MARIA",
            documentNumber: "L898902C3",
            nationalityCountryCode: "UTO",
            birthdate:  dateFormatter.date(from: "740812")!,
            sex: .female,
            expiryDate: dateFormatter.date(from: "120415")!,
            optionalData: "ZE184226B",
            optionalData2: nil
        )

        XCTAssertEqual(parser.parse(mrzString: mrzString), result)
    }

    func testTD3RussianInternationalPassport() {
        let mrzString = """
                        P<RUSIMIAREK<<EVGENII<<<<<<<<<<<<<<<<<<<<<<<
                        1104000008RUS8209120M2601157<<<<<<<<<<<<<<06
                        """
        let result = MRZResult(
            format: .td3,
            documentType: .passport,
            documentTypeAdditional: nil,
            countryCode: "RUS",
            surnames: "IMIAREK",
            givenNames: "EVGENII",
            documentNumber: "110400000",
            nationalityCountryCode: "RUS",
            birthdate:  dateFormatter.date(from: "820912")!,
            sex: .male,
            expiryDate: dateFormatter.date(from: "260115")!,
            optionalData: "",
            optionalData2: nil
        )

        XCTAssertEqual(parser.parse(mrzString: mrzString), result)
    }

    func testTD3RussianPassport() {
        let mrzString = """
                        PNRUSZDRIL7K<<SERGEQ<ANATOL9EVI3<<<<<<<<<<<<
                        3919353498RUS7207233M<<<<<<<4151218910003<50
                        """
        let result = MRZResult(
            format: .td3,
            documentType: .passport,
            documentTypeAdditional: "N",
            countryCode: "RUS",
            surnames: "ZDRIL7K",
            givenNames: "SERGEQ ANATOL9EVI3",
            documentNumber: "391935349",
            nationalityCountryCode: "RUS",
            birthdate:  dateFormatter.date(from: "720723")!,
            sex: .male,
            expiryDate: nil,
            optionalData: "4151218910003",
            optionalData2: nil
        )

        XCTAssertEqual(parser.parse(mrzString: mrzString), result)
    }

    func testTD3NetherlandsPassport() {
        let mrzString = """
                        P<NLDDE<BRUIJN<<WILLEKE<LISELOTTE<<<<<<<<<<<
                        SPECI20142NLD6503101F2403096999999990<<<<<84
                        """
        let result = MRZResult(
            format: .td3,
            documentType: .passport,
            documentTypeAdditional: nil,
            countryCode: "NLD",
            surnames: "DE BRUIJN",
            givenNames: "WILLEKE LISELOTTE",
            documentNumber: "SPECI2014",
            nationalityCountryCode: "NLD",
            birthdate:  dateFormatter.date(from: "650310")!,
            sex: .female,
            expiryDate: dateFormatter.date(from: "240309")!,
            optionalData: "999999990",
            optionalData2: nil
        )

        XCTAssertEqual(parser.parse(mrzString: mrzString), result)
    }

    func testMRVA() {
        let mrzString = """
                        V<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<
                        L8988901C4XXX4009078F96121096ZE184226B<<<<<<
                        """
        let result = MRZResult(
            format: .td3,
            documentType: .visa,
            documentTypeAdditional: nil,
            countryCode: "UTO",
            surnames: "ERIKSSON",
            givenNames: "ANNA MARIA",
            documentNumber: "L8988901C",
            nationalityCountryCode: "XXX",
            birthdate:  dateFormatter.date(from: "19400907")!,
            sex: .female,
            expiryDate: dateFormatter.date(from: "19961210")!,
            optionalData: "6ZE184226B",
            optionalData2: nil
        )

        XCTAssertEqual(parser.parse(mrzString: mrzString), result)
    }

    func testMRVB() {
        let mrzString = """
                        V<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<
                        L8988901C4XXX4009078F9612109<<<<<<<<
                        """
        let result = MRZResult(
            format: .td2,
            documentType: .visa,
            documentTypeAdditional: nil,
            countryCode: "UTO",
            surnames: "ERIKSSON",
            givenNames: "ANNA MARIA",
            documentNumber: "L8988901C",
            nationalityCountryCode: "XXX",
            birthdate:  dateFormatter.date(from: "19400907")!,
            sex: .female,
            expiryDate: dateFormatter.date(from: "19961210")!,
            optionalData: "",
            optionalData2: nil
        )

        XCTAssertEqual(parser.parse(mrzString: mrzString), result)
    }
}
