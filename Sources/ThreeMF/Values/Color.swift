import Foundation
import Nodal

public struct Color: Hashable, Sendable {
    public typealias Component = UInt8
    public let red: Component
    public let green: Component
    public let blue: Component
    public let alpha: Component

    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 0xFF) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public var isOpaque: Bool { alpha == 0xFF }
}

public extension Color {
    static var white: Color { .init(red: 0xFF, green: 0xFF, blue: 0xFF) }
}

extension Color: XMLValueCodable {
    public init(xmlStringValue hexString: String, for node: Node) throws {
        guard hexString.hasPrefix("#") else {
            throw XMLValueError.invalidFormat(expected: "Color", found: hexString)
        }
        var string = hexString
        string.removeFirst()

        guard var number = Int(string, radix: 16) else {
            throw XMLValueError.invalidFormat(expected: "Color", found: hexString)
        }

        if string.count == 8 {
            alpha = UInt8(number & 0xFF)
            number = number >> 8
        } else if string.count == 6 {
            alpha = 0xFF
        } else {
            throw XMLValueError.invalidFormat(expected: "Color", found: hexString)
        }

        red = UInt8(number >> 16 & 0xFF)
        green = UInt8(number >> 8 & 0xFF)
        blue = UInt8(number >> 0 & 0xFF)
    }

    public func xmlStringValue(for node: Node) -> String {
        if alpha == 0xFF {
            String(format: "#%02x%02x%02x", red, green, blue)
        } else {
            String(format: "#%02x%02x%02x%02x", red, green, blue, alpha)
        }
    }
}
