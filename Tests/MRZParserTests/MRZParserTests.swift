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

            parser = MRZParser()
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
                            I<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<
                            D231458907UTO7408122F1204159<<<<<<<6
                            """
            let result = MRZResult(
                format: .td2,
                documentType: .id,
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

        func testMRVA() {
            let mrzString = """
                            V<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<
                            L8988901C4XXX4009078F96121096ZE184226B<<<<<<
                            """
            let result = MRZResult(
                format: .mrva,
                documentType: .visa,
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
            let parser = MRZParser()
            let mrzString = """
                            V<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<
                            L8988901C4XXX4009078F9612109<<<<<<<<
                            """
            let result = MRZResult(
                format: .mrvb,
                documentType: .visa,
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
