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
    private let formatter = MRZFieldFormatter()

    // MARK: Parsing
    public func parse(mrzLines: [String]) -> MRZResult? {
        guard let uniformedLineLength = uniformedLineLength(for: mrzLines),
              let format = mrzFormat(lineLenght: uniformedLineLength) else { return nil }
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

    // MARK: Line validation
    public func isLineValid(line: String) -> Bool {
        guard let format = mrzFormat(lineLenght: line.count) else { return false }
        switch format {
        case .td1:
            return TD1.isLineValid(line: line)
        case .td2:
            return TD2.isLineValid(line: line)
        case .td3:
            return TD3.isLineValid(line: line)
        }
    }

    // MARK: MRZ-Format detection
    private func mrzFormat(lineLenght: Int) -> MRZFormat? {
        [MRZFormat.td1: TD1.lineLength, MRZFormat.td2: TD2.lineLength, MRZFormat.td3: TD3.lineLength]
            .first(where: { $0.value == lineLenght })?.key
    }

    private func uniformedLineLength(for mrzLines: [String]) -> Int? {
        guard let lineLength = mrzLines.first?.count,
              !mrzLines.contains(where: { $0.count != lineLength }) else { return nil }
        return lineLength
    }
}

