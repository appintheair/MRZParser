    import XCTest
    @testable import MRZParser

    final class MRZParserTests: XCTestCase {
        private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            return formatter
        }()

        func testTD1() {
            let parser = MRZParser()
            let mrzString = """
                            I<UTOD231458907<<<<<<<<<<<<<<<
                            7408122F1204159UTO<<<<<<<<<<<6
                            ERIKSSON<<ANNA<MARIA<<<<<<<<<<
                            """
            let result = MRZResult(
                documentType: "I",
                countryCode: "UTO",
                surnames: "ERIKSSON",
                givenNames: "ANNA MARIA",
                documentNumber: "D23145890",
                nationalityCountryCode: "UTO",
                birthdate:  dateFormatter.date(from: "740812"),
                sex: "FEMALE",
                expiryDate: dateFormatter.date(from: "120415"),
                personalNumber: "",
                personalNumber2: "",
                isDocumentNumberValid: true,
                isBirthdateValid: true,
                isExpiryDateValid: true,
                isPersonalNumberValid: nil,
                allCheckDigitsValid: true
            )

            XCTAssertEqual(parser.parse(mrzString: mrzString), result)
        }

        func testTD2() {
            let parser = MRZParser()
            let mrzString = """
                            I<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<
                            D231458907UTO7408122F1204159<<<<<<<6
                            """
            let result = MRZResult(
                documentType: "I",
                countryCode: "UTO",
                surnames: "ERIKSSON",
                givenNames: "ANNA MARIA",
                documentNumber: "D23145890",
                nationalityCountryCode: "UTO",
                birthdate:  dateFormatter.date(from: "740812"),
                sex: "FEMALE",
                expiryDate: dateFormatter.date(from: "120415"),
                personalNumber: "",
                personalNumber2: nil,
                isDocumentNumberValid: true,
                isBirthdateValid: true,
                isExpiryDateValid: true,
                isPersonalNumberValid: nil,
                allCheckDigitsValid: true
            )

            XCTAssertEqual(parser.parse(mrzString: mrzString), result)
        }

        func testTD3() {
            let parser = MRZParser()
            let mrzString = """
                            P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<
                            L898902C36UTO7408122F1204159ZE184226B<<<<<10
                            """
            let result = MRZResult(
                documentType: "P",
                countryCode: "UTO",
                surnames: "ERIKSSON",
                givenNames: "ANNA MARIA",
                documentNumber: "L898902C3",
                nationalityCountryCode: "UTO",
                birthdate:  dateFormatter.date(from: "740812"),
                sex: "FEMALE",
                expiryDate: dateFormatter.date(from: "120415"),
                personalNumber: "ZE184226B",
                personalNumber2: nil,
                isDocumentNumberValid: true,
                isBirthdateValid: true,
                isExpiryDateValid: true,
                isPersonalNumberValid: true,
                allCheckDigitsValid: true
            )

            XCTAssertEqual(parser.parse(mrzString: mrzString), result)
        }

        private func date(from string: String) -> Date {
            let dateStringFormatter = DateFormatter()
            dateStringFormatter.dateFormat = "yyyy-MM-dd"
            dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            return dateStringFormatter.date(from: string)!
        }
    }


