import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// ST_Matrix3D
public struct Matrix3D: XMLStringConvertible {
    public let values: [[Double]]

    public init(values: [[Double]]) {
        guard values.count == 4, values.allSatisfy({ $0.count == 3 }) else {
            preconditionFailure("Matrix must have four rows and three columns")
        }
        self.values = values
    }

    init(xmlString: String) throws(Error) {
        let flatValues = xmlString.split(separator: " ").compactMap(Double.init)
        guard flatValues.count == 12 else { throw .malformedTransform(xmlString) }
        values = (0..<4).map { Array(flatValues[($0 * 3)..<(($0 + 1) * 3)]) }
    }

    var xmlStringValue: String {
        values.map { String(format: "%g %g %g", $0[0], $0[1], $0[2]) }.joined(separator: " ")
    }
}
