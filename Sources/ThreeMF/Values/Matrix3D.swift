import Foundation
import Nodal

// ST_Matrix3D
/// An affine 3D transform, as a 4×3 matrix.
///
/// The three columns hold the transformed basis vectors and the fourth row holds the translation;
/// the implied last column is always `0 0 1`. This is the `ST_Matrix3D` of the 3MF spec, written as
/// twelve space-separated numbers, and is what ``Item/transform`` and ``Component/transform`` hold.
public struct Matrix3D: Sendable, XMLValueCodable {
    /// The matrix as four rows of three columns, in row-major order.
    public let values: [[Double]]

    /// Creates a transform from four rows of three columns.
    /// - Parameter values: The matrix rows.
    /// - Precondition: `values` has exactly four rows of exactly three columns each.
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
