import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:pbspeculartexturedisplayproperties
public struct SpecularTextureDisplayProperties: Resource, XMLElementComposable {
    static let elementIdentifier = Materials.specularTextureDisplayProperties

    public var id: ResourceID
    public var name: String
    public var specularTextureID: ResourceID
    public var glossinessTextureID: ResourceID
    public var diffuseFactor: Color?
    public var specularFactor: Color?
    public var glossinessFactor: Double?

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

internal extension SpecularTextureDisplayProperties {
    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            .m.id: id,
            .m.name: name,
            .m.specularTextureID: specularTextureID,
            .m.glossinessTextureID: glossinessTextureID,
            .m.diffuseFactor: diffuseFactor,
            .m.specularFactor: specularFactor,
            .m.glossinessFactor: glossinessFactor
        ]
    }

    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement[.m.id]
        name = try xmlElement[.m.name]
        specularTextureID = try xmlElement[.m.specularTextureID]
        glossinessTextureID = try xmlElement[.m.glossinessTextureID]
        diffuseFactor = try? xmlElement[.m.diffuseFactor]
        specularFactor = try? xmlElement[.m.specularFactor]
        glossinessFactor = try? xmlElement[.m.glossinessFactor]
    }
}
