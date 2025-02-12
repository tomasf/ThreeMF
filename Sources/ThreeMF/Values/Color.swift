import Foundation
import Nodal

// CT_Color and m:color
public struct Color: Hashable {
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

extension Color: XMLStringConvertible {
    internal init(xmlString hexString: String) throws(Error) {
        guard hexString.hasPrefix("#") else {
            throw .malformedColorString(hexString)
        }
        var string = hexString
        string.removeFirst()

        guard var number = Int(string, radix: 16) else {
            throw .malformedColorString(hexString)
        }

        if string.count == 8 {
            alpha = UInt8(number & 0xFF)
            number = number >> 8
        } else if string.count == 6 {
            alpha = 0xFF
        } else {
            throw .malformedColorString(hexString)
        }

        red = UInt8(number >> 16 & 0xFF)
        green = UInt8(number >> 8 & 0xFF)
        blue = UInt8(number >> 0 & 0xFF)
    }

    var xmlStringValue: String {
        String(format: "#%02x%02x%02x%02x", red, green, blue, alpha)
    }
}

extension Color: XMLElementComposable {
    static let elementIdentifier = Materials.color

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [.m.colorAttribute: self]
    }

    init(xmlElement: Node) throws(Error) {
        self = try xmlElement[.m.colorAttribute]
    }
}
