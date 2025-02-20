import Foundation
import Nodal

// m:pbspeculartexturedisplayproperties
@XMLCodable
public struct SpecularTextureDisplayProperties: Resource {
    static public let elementName: ExpandedName = Materials.specularTextureDisplayProperties

    @Attribute(.id) public var id: ResourceID
    @Attribute(.name) public var name: String
    @Attribute(.specularTextureID) public var specularTextureID: ResourceID
    @Attribute(.glossinessTextureID) public var glossinessTextureID: ResourceID
    @Attribute(.diffuseFactor) public var diffuseFactor: Color?
    @Attribute(.specularFactor) public var specularFactor: Color?
    @Attribute(.glossinessFactor) public var glossinessFactor: Double?

    public init(id: ResourceID, name: String, specularTextureID: ResourceID, glossinessTextureID: ResourceID, diffuseFactor: Color? = nil, specularFactor: Color? = nil, glossinessFactor: Double? = nil) {
        self.id = id
        self.name = name
        self.specularTextureID = specularTextureID
        self.glossinessTextureID = glossinessTextureID
        self.diffuseFactor = diffuseFactor
        self.specularFactor = specularFactor
        self.glossinessFactor = glossinessFactor
    }
}

public extension SpecularTextureDisplayProperties {
    var effectiveFactors: (diffuseFactor: Color, specularFactor: Color, glossinessFactor: Double) {
        (diffuseFactor ?? .white, specularFactor ?? .white, glossinessFactor ?? 1)
    }
}
