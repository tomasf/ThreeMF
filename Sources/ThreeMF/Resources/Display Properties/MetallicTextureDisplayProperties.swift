import Foundation
import Nodal

// m:pbmetallictexturedisplayproperties
public struct MetallicTextureDisplayProperties: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.metallicTexturedDisplayProperties

    public var id: ResourceID
    public var name: String
    public var metallicTextureID: ResourceID
    public var roughnessTextureID: ResourceID
    public var baseColorFactor: Color?
    public var metallicFactor: Double?
    public var roughnessFactor: Double?

    public init(id: ResourceID, name: String, metallicTextureID: ResourceID, roughnessTextureID: ResourceID, baseColorFactor: Color? = nil, metallicFactor: Double? = nil, roughnessFactor: Double? = nil) {
        self.id = id
        self.name = name
        self.metallicTextureID = metallicTextureID
        self.roughnessTextureID = roughnessTextureID
        self.baseColorFactor = baseColorFactor
        self.metallicFactor = metallicFactor
        self.roughnessFactor = roughnessFactor
    }

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.setValue(name, forAttribute: .name)
        element.setValue(metallicTextureID, forAttribute: .metallicTextureID)
        element.setValue(roughnessTextureID, forAttribute: .roughnessTextureID)
        element.setValue(baseColorFactor, forAttribute: .baseColorFactor)
        element.setValue(metallicFactor, forAttribute: .metallicFactor)
        element.setValue(roughnessFactor, forAttribute: .roughnessFactor)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        name = try element.value(forAttribute: .name)
        metallicTextureID = try element.value(forAttribute: .metallicTextureID)
        roughnessTextureID = try element.value(forAttribute: .roughnessTextureID)
        baseColorFactor = try element.value(forAttribute: .baseColorFactor)
        metallicFactor = try element.value(forAttribute: .metallicFactor)
        roughnessFactor = try element.value(forAttribute: .roughnessFactor)
    }
}

public extension MetallicTextureDisplayProperties {
    var effectiveFactors: (baseColorFactor: Color, metallicFactor: Double, roughnessFactor: Double) {
        (baseColorFactor ?? .white, metallicFactor ?? 1, roughnessFactor ?? 1)
    }
}
