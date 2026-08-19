import Foundation
import Nodal

// m:pbspeculartexturedisplayproperties
/// Specular-glossiness appearance driven by textures rather than single values, from the materials
/// extension.
///
/// Display properties say how a material should *look* when rendered. They describe appearance only,
/// and change neither the geometry nor the materials themselves. A material or color group points at
/// one with its display properties id.
public struct SpecularTextureDisplayProperties: Resource {
    static public let elementName: ExpandedName = Materials.specularTextureDisplayProperties

    public var id: ResourceID

    /// A name for this appearance.
    public var name: String

    /// The ``Texture2D`` whose values give the color of the surface's highlights.
    public var specularTextureID: ResourceID

    /// The ``Texture2D`` whose values say how tight the highlights are at each point.
    public var glossinessTextureID: ResourceID

    /// A color multiplied into the diffuse color. `nil` means white, leaving it unchanged.
    public var diffuseFactor: Color?

    /// A color multiplied into the specular texture. `nil` means white, leaving it unchanged.
    public var specularFactor: Color?

    /// A multiplier applied to the glossiness texture. `nil` means 1, leaving it unchanged.
    public var glossinessFactor: Double?

    /// Creates a set of texture-driven specular display properties.
    /// - Parameters:
    ///   - id: The resource's id, unique within its model file.
    ///   - name: A name for the appearance.
    ///   - specularTextureID: The texture holding specular colors.
    ///   - glossinessTextureID: The texture holding glossiness values.
    ///   - diffuseFactor: A color multiplied into the diffuse color.
    ///   - specularFactor: A color multiplied into the specular texture.
    ///   - glossinessFactor: A multiplier for the glossiness texture.
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

/// Resolving unset factors.
public extension SpecularTextureDisplayProperties {
    /// The factors actually in force, substituting the spec's defaults for any that aren't set.
    var effectiveFactors: (diffuseFactor: Color, specularFactor: Color, glossinessFactor: Double) {
        (diffuseFactor ?? .white, specularFactor ?? .white, glossinessFactor ?? 1)
    }
}
