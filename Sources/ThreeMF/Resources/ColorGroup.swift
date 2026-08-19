import Foundation
import Nodal

// m:colorgroup
/// A group of colors that objects and triangles can refer to by index.
///
/// From the materials extension. An object or triangle names the group with a property group id and
/// picks a color with an index into ``colors``.
public struct ColorGroup: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.colorGroup

    public var id: ResourceID

    /// Display properties describing how these colors should look when rendered, if any.
    public var displayPropertiesID: ResourceID?

    /// The colors, referred to by their index in this array.
    public var colors: [Color]

    /// Creates a color group.
    /// - Parameters:
    ///   - id: The group's id, unique within its model file.
    ///   - displayPropertiesID: Display properties for these colors.
    ///   - colors: The colors, in index order.
    public init(id: ResourceID, displayPropertiesID: ResourceID? = nil, colors: [Color] = []) {
        self.id = id
        self.displayPropertiesID = displayPropertiesID
        self.colors = colors
    }

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.setValue(displayPropertiesID, forAttribute: .displayPropertiesID)
        element.encode(colors.map { ColorItem(color: $0) }, elementName: Materials.color)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        displayPropertiesID = try element.value(forAttribute: .displayPropertiesID)
        let items: [ColorItem] = try element.decode(elementName: Materials.color)
        colors = items.map(\.color)
    }
}

/// Building up a color group.
public extension ColorGroup {
    @discardableResult

    /// Appends a color and returns the index to refer to it by.
    /// - Parameter color: The color to add.
    /// - Returns: The index of the added color.
    mutating func addColor(_ color: Color) -> ResourceIndex {
        colors.append(color)
        return colors.endIndex - 1
    }
}

// m:color
internal struct ColorItem: Sendable, XMLElementCodable {
    var color: Color

    init(color: Color) {
        self.color = color
    }

    public func encode(to element: Node) {
        element.setValue(color, forAttribute: .color)
    }

    public init(from element: Node) throws {
        color = try element.value(forAttribute: .color)
    }
}
