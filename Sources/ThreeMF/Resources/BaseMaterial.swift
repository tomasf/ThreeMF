import Foundation
import Nodal

// basematerials
/// A group of materials that objects and triangles can refer to by index.
///
/// Base materials are the core spec's way of saying what something is made of: a name for the
/// material, and a color to show it in.
public struct BaseMaterialGroup: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Core.baseMaterials

    public var id: ResourceID

    /// Display properties describing how these materials should look when rendered, if any.
    public var displayPropertiesID: ResourceID? // Points to a <displayproperties>

    /// The materials, referred to by their index in this array.
    public var properties: [BaseMaterial]

    /// Creates a base material group.
    /// - Parameters:
    ///   - id: The group's id, unique within its model file.
    ///   - displayPropertiesID: Display properties for these materials.
    ///   - properties: The materials, in index order.
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
/// One material in a ``BaseMaterialGroup``: what it's called and what color to show it in.
public struct BaseMaterial: Sendable, XMLElementCodable {
    /// The material's name, identifying what the object is made of.
    public let name: String

    /// The color to display the material in. This is how a viewer should show it, not necessarily
    /// the material's own color.
    public let displayColor: Color

    /// Creates a base material.
    /// - Parameters:
    ///   - name: The material's name.
    ///   - displayColor: The color to display it in.
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
