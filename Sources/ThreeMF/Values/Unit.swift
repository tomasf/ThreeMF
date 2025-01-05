import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

public enum Unit: String, Sendable {
    case micron
    case millimeter
    case centimeter
    case inch
    case foot
    case meter
}

extension Unit: StringConvertible {
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
