//
//  MRZParser.swift
//
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Foundation

public class MRZParser {
    private let formatter: MRZFieldFormatter

    private enum MRZFormat: Int {
        case td1, td2, td3, invalid
    }

    public init(ocrCorrection: Bool = false) {
        formatter = MRZFieldFormatter(ocrCorrection: ocrCorrection)
    }

    // MARK: Parsing
    public func parse(mrzLines: [String]) -> MRZResult? {
        switch self.mrzFormat(from: mrzLines) {
        case .td1:
            return TD1(from: mrzLines, using: formatter).result
        case .td2:
            return TD2(from: mrzLines, using: formatter).result
        case .td3:
            return TD3(from: mrzLines, using: formatter).result
        case .invalid:
            return nil
        }
    }

    public func parse(mrzString: String) -> MRZResult? {
        return parse(mrzLines: mrzString.components(separatedBy: "\n"))
    }

    // MARK: Line validation
    public func isLineValid(line: String) -> Bool {
        guard let format = [MRZFormat.td1: TD1.lineLength, MRZFormat.td2: TD2.lineLength, .td3: TD3.lineLength]
                .first(where: { $0.value == line.count })?.key else { return false }

        switch format {
        case .td1:
            return TD1.isLineValid(line: line)
        case .td2:
            return TD2.isLineValid(line: line)
        case .td3:
            return TD3.isLineValid(line: line)
        case .invalid:
            return false
        }
    }

    // MARK: MRZ-Format detection
    private func mrzFormat(from mrzLines: [String]) -> MRZFormat {
        switch mrzLines.count {
        case 2:
            let lineLength = uniformedLineLength(for: mrzLines)
            let possibleFormats = [MRZFormat.td2: TD2.lineLength, .td3: TD3.lineLength]

            for (format, requiredLineLength) in possibleFormats where lineLength == requiredLineLength {
                return format
            }

            return .invalid
        case 3:
            return (uniformedLineLength(for: mrzLines) == TD1.lineLength) ? .td1 : .invalid
        default:
            return .invalid
        }
    }

    private func uniformedLineLength(for mrzLines: [String]) -> Int? {
        guard let lineLength = mrzLines.first?.count else {
            return nil
        }

        if mrzLines.contains(where: { $0.count != lineLength }) {
            return nil
        }

        return lineLength
    }
}

