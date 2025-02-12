import Foundation
import Nodal

// m:pbmetallictexturedisplayproperties
public struct MetallicTextureDisplayProperties: Resource, XMLElementComposable {
    static let elementIdentifier = Materials.metallicTexturedDisplayProperties

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
}

public extension MetallicTextureDisplayProperties {
    var effectiveFactors: (baseColorFactor: Color, metallicFactor: Double, roughnessFactor: Double) {
        (baseColorFactor ?? .white, metallicFactor ?? 1, roughnessFactor ?? 1)
    }
}

internal extension MetallicTextureDisplayProperties {
    var attributes: [AttributeIdentifier : (any XMLStringConvertible)?] {
        [
            .m.id: id,
            .m.name: name,
            .m.metallicTextureID: metallicTextureID,
            .m.roughnessTextureID: roughnessTextureID,
            .m.baseColorFactor: baseColorFactor,
            .m.metallicFactor: metallicFactor,
            .m.roughnessFactor: roughnessFactor
        ]
    }
    
    init(xmlElement: Node) throws(Error) {
        id = try xmlElement[.m.id]
        name = try xmlElement[.m.name]
        metallicTextureID = try xmlElement[.m.metallicTextureID]
        roughnessTextureID = try xmlElement[.m.roughnessTextureID]
        baseColorFactor = try? xmlElement[.m.baseColorFactor]
        metallicFactor = try? xmlElement[.m.metallicFactor]
        roughnessFactor = try? xmlElement[.m.roughnessFactor]
    }
}
