//
//  MRZParser.swift
//
//
//  Created by Roman Mazeev on 15.06.2021.
//

import Foundation

enum MRZFormat {
    case td1, td2, td3
}

public struct MRZParser {
    private let formatter: MRZFieldFormatter

    public init(isOCRCorrectionEnabled: Bool = false) {
        formatter = MRZFieldFormatter(isOCRCorrectionEnabled: isOCRCorrectionEnabled)
    }

    // MARK: Parsing
    public func parse(mrzLines: [String]) -> MRZResult? {
        guard let format = mrzFormat(from: mrzLines) else { return nil }
        switch format {
        case .td1:
            return TD1(from: mrzLines, using: formatter).result
        case .td2:
            return TD2(from: mrzLines, using: formatter).result
        case .td3:
            return TD3(from: mrzLines, using: formatter).result
        }
    }

    public func parse(mrzString: String) -> MRZResult? {
        return parse(mrzLines: mrzString.components(separatedBy: "\n"))
    }

    // MARK: Line validation by charactes count
    public func isLineValid(line: String) -> Bool {
        [MRZFormat.td1: TD1.lineLength, MRZFormat.td2: TD2.lineLength, MRZFormat.td3: TD3.lineLength]
            .first(where: { $0.value == line.count }) != nil
    }

    // MARK: MRZ-Format detection
    private func mrzFormat(from mrzLines: [String]) -> MRZFormat? {
        switch mrzLines.count {
        case 2:
            let lineLength = uniformedLineLength(for: mrzLines)
            let possibleFormats = [MRZFormat.td2: TD2.lineLength, .td3: TD3.lineLength]

            return possibleFormats.first(where: { $0.value == lineLength })?.key
        case 3:
            return (uniformedLineLength(for: mrzLines) == TD1.lineLength) ? .td1 : nil
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

