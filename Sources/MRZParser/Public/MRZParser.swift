//
//  MRZParser.swift
//
//
//  Created by Roman Mazeev on 15.06.2021.
//

public struct MRZParser {
    private let formatter: MRZFieldFormatter

    public init(isOCRCorrectionEnabled: Bool) {
        formatter = MRZFieldFormatter(isOCRCorrectionEnabled: isOCRCorrectionEnabled)
    }

    init(formatter: MRZFieldFormatter) {
        self.formatter = formatter
    }

    // MARK: Parsing
    public func parse(mrzLines: [String]) -> MRZResult? {
        guard let format = mrzFormat(from: mrzLines) else { return nil }

        let mrzCode: MRZCode = MRZCodeFactory().create(
            from: mrzLines,
            format: format,
            formatter: formatter
        )

        guard mrzCode.isValid else { return nil }

        return .init(
            format: format,
            documentType: {
                guard let documentTypeFirstElement = mrzCode.documentTypeField.value.first else { return .undefined }
                return MRZResult.DocumentType.allCases.first(where: {
                    $0.identifiers.contains(String(documentTypeFirstElement))
                }) ?? .undefined
            }(),
            countryCode: mrzCode.countryCodeField.value,
            surnames: mrzCode.namesField.surnames,
            givenNames: mrzCode.namesField.givenNames,
            documentNumber: mrzCode.documentNumberField.value,
            nationalityCountryCode: mrzCode.nationalityField.value,
            birthdate: mrzCode.birthdateField.value,
            sex: MRZResult.Sex.allCases.first(where: {
                $0.identifier.contains(mrzCode.sexField.value)
            }) ?? .unspecified,
            expiryDate: mrzCode.expiryDateField.value,
            optionalData: mrzCode.optionalDataField.value,
            optionalData2: mrzCode.optionalData2Field?.value
        )
    }

    public func parse(mrzString: String) -> MRZResult? {
        return parse(mrzLines: mrzString.components(separatedBy: "\n"))
    }

    // MARK: MRZ-Format detection
    private func mrzFormat(from mrzLines: [String]) -> MRZFormat? {
        switch mrzLines.count {
        case MRZFormat.td2.linesCount,  MRZFormat.td3.linesCount:
            return [.td2, .td3].first(where: { $0.lineLenth == uniformedLineLength(for: mrzLines) })
        case MRZFormat.td1.linesCount:
            return (uniformedLineLength(for: mrzLines) == MRZFormat.td1.lineLenth) ? .td1 : nil
        default:
            return nil
        }
    }

    private func uniformedLineLength(for mrzLines: [String]) -> Int? {
        guard let lineLength = mrzLines.first?.count,
              !mrzLines.contains(where: { $0.count != lineLength }) else { return nil }
        return lineLength
    }
}

