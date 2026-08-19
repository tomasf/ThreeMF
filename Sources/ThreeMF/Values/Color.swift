import Foundation
import Nodal

/// An 8-bit sRGB color with an alpha channel.
///
/// Written as `#RRGGBB`, or `#RRGGBBAA` when it isn't fully opaque. Used by ``ColorGroup`` and as
/// an object's display color.
public struct Color: Hashable, Sendable {
    /// The storage for one channel: 0 through 255.
    public typealias Component = UInt8

    /// The red channel.
    public let red: Component

    /// The green channel.
    public let green: Component

    /// The blue channel.
    public let blue: Component

    /// The alpha channel, where 255 is fully opaque.
    public let alpha: Component

    /// Creates a color from its channels.
    /// - Parameters:
    ///   - red: The red channel.
    ///   - green: The green channel.
    ///   - blue: The blue channel.
    ///   - alpha: The alpha channel. Defaults to fully opaque.
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 0xFF) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// Whether the color is fully opaque, and so can be written without an alpha channel.
    public var isOpaque: Bool { alpha == 0xFF }
}

/// Common colors.
public extension Color {
    /// Opaque white.
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
