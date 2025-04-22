import Foundation
import Nodal

// m:colorgroup
public struct ColorGroup: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.colorGroup

    public var id: ResourceID
    public var displayPropertiesID: ResourceID?
    public var colors: [Color]

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

public extension ColorGroup {
    @discardableResult
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
