import Foundation
import Nodal

// m:pbmetallictexturedisplayproperties
@XMLCodable
public struct MetallicTextureDisplayProperties: Resource {
    static public let elementName: ExpandedName = Materials.metallicTexturedDisplayProperties

    @Attribute(.id) public var id: ResourceID
    @Attribute(.name) public var name: String
    @Attribute(.metallicTextureID) public var metallicTextureID: ResourceID
    @Attribute(.roughnessTextureID) public var roughnessTextureID: ResourceID
    @Attribute(.baseColorFactor) public var baseColorFactor: Color?
    @Attribute(.metallicFactor) public var metallicFactor: Double?
    @Attribute(.roughnessFactor) public var roughnessFactor: Double?

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
