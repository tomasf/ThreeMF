import Foundation
import Nodal

// ST_Matrix3D
public struct Matrix3D: Sendable, XMLValueCodable {
    public let values: [[Double]]

    public init(values: [[Double]]) {
        guard values.count == 4, values.allSatisfy({ $0.count == 3 }) else {
            preconditionFailure("Matrix must have four rows and three columns")
        }
        self.values = values
    }

    public init(xmlStringValue string: String, for node: Node) throws {
        let flatValues = string.split(separator: " ").compactMap(Double.init)
        guard flatValues.count == 12 else { throw XMLValueError.invalidFormat(expected: "Transform (12 doubles)", found: string) }
        values = (0..<4).map { Array(flatValues[($0 * 3)..<(($0 + 1) * 3)]) }
    }

    public func xmlStringValue(for node: Node) -> String {
        values.map { String(format: "%g %g %g", $0[0], $0[1], $0[2]) }.joined(separator: " ")
    }
}
