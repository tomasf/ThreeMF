import Foundation
import Nodal

// basematerials
public struct BaseMaterialGroup: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Core.baseMaterials

    public var id: ResourceID
    public var displayPropertiesID: ResourceID? // Points to a <displayproperties>
    public var properties: [BaseMaterial]

    public init(id: ResourceID, displayPropertiesID: ResourceID? = nil, properties: [BaseMaterial]) {
        self.id = id
        self.displayPropertiesID = displayPropertiesID
        self.properties = properties
    }

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.setValue(displayPropertiesID, forAttribute: .displayPropertiesID)
        element.encode(properties, elementName: Core.base)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        displayPropertiesID = try element.value(forAttribute: .displayPropertiesID)
        properties = try element.decode(elementName: Core.base)
    }
}

// base
public struct BaseMaterial: Sendable, XMLElementCodable {
    public let name: String
    public let displayColor: Color

    public init(name: String, displayColor: Color) {
        self.name = name
        self.displayColor = displayColor
    }

    public func encode(to element: Node) {
        element.setValue(name, forAttribute: .name)
        element.setValue(displayColor, forAttribute: .displayColor)
    }

    public init(from element: Node) throws {
        name = try element.value(forAttribute: .name)
        displayColor = try element.value(forAttribute: .displayColor)
    }
}
