import Foundation
import Nodal

/// The unit that a model's coordinates are expressed in.
///
/// Every length in a model file, vertex coordinates and transforms alike, is a plain number, and
/// this is what gives those numbers a size. It's set per model, in ``Model/unit``.
public enum Unit: String, Sendable, XMLValueCodable {
    /// One thousandth of a millimetre.
    case micron

    /// One millimetre. The default when a model doesn't say.
    case millimeter

    /// Ten millimetres.
    case centimeter

    /// 25.4 millimetres.
    case inch

    /// 304.8 millimetres.
    case foot

    /// One thousand millimetres.
    case meter
}

/// Convenience for working with units.
public extension Unit {
    /// The unit a model is in when it doesn't specify one, per the 3MF spec: millimetres.
    static let `default` = Self.millimeter

    /// How many millimetres one unit measures.
    ///
    /// Multiply a coordinate by this to convert it to millimetres, or divide to convert the other way.
    var millimetersPerUnit: Double {
        switch self {
        case .micron: return 0.001
        case .millimeter: return 1
        case .centimeter: return 10
        case .inch: return 25.4
        case .foot: return 304.8
        case .meter: return 1000
        }
    }
}
