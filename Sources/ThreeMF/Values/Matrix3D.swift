import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// ST_Matrix3D
public struct Matrix3D: StringConvertible {
    let values: [[Double]]

    init(string: String) throws(Error) {
        let flatValues = string.split(separator: " ").compactMap(Double.init)
        guard flatValues.count == 12 else { throw .malformedTransform(string) }
        values = (0..<4).map { Array(flatValues[($0 * 3)..<(($0 + 1) * 3)]) }
    }

    var string: String {
        values.map { String(format: "%g %g %g %g", $0[0], $0[1], $0[2], $0[3]) }.joined(separator: " ")
    }
}
