import Foundation
import Nodal

// m:pbspeculartexturedisplayproperties
public struct SpecularTextureDisplayProperties: Resource {
    static public let elementName: ExpandedName = Materials.specularTextureDisplayProperties

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

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.setValue(name, forAttribute: .name)
        element.setValue(specularTextureID, forAttribute: .specularTextureID)
        element.setValue(glossinessTextureID, forAttribute: .glossinessTextureID)
        element.setValue(diffuseFactor, forAttribute: .diffuseFactor)
        element.setValue(specularFactor, forAttribute: .specularFactor)
        element.setValue(glossinessFactor, forAttribute: .glossinessFactor)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        name = try element.value(forAttribute: .name)
        specularTextureID = try element.value(forAttribute: .specularTextureID)
        glossinessTextureID = try element.value(forAttribute: .glossinessTextureID)
        diffuseFactor = try element.value(forAttribute: .diffuseFactor)
        specularFactor = try element.value(forAttribute: .specularFactor)
        glossinessFactor = try element.value(forAttribute: .glossinessFactor)
    }
}

public extension SpecularTextureDisplayProperties {
    var effectiveFactors: (diffuseFactor: Color, specularFactor: Color, glossinessFactor: Double) {
        (diffuseFactor ?? .white, specularFactor ?? .white, glossinessFactor ?? 1)
    }
}
