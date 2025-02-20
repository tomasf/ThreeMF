import Foundation
import Nodal

public enum Unit: String, Sendable, XMLValueCodable {
    case micron
    case millimeter
    case centimeter
    case inch
    case foot
    case meter
}

public extension Unit {
    static let `default` = Self.millimeter

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
