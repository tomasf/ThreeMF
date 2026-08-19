import Foundation
import Nodal

// m:pbmetallictexturedisplayproperties
/// Metallic-roughness appearance driven by textures rather than single values, from the materials
/// extension.
///
/// Display properties say how a material should *look* when rendered. They describe appearance only,
/// and change neither the geometry nor the materials themselves. A material or color group points at
/// one with its display properties id.
public struct MetallicTextureDisplayProperties: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.metallicTexturedDisplayProperties

    public var id: ResourceID

    /// A name for this appearance.
    public var name: String

    /// The ``Texture2D`` whose values say how metallic each point of the surface is.
    public var metallicTextureID: ResourceID

    /// The ``Texture2D`` whose values say how rough each point of the surface is.
    public var roughnessTextureID: ResourceID

    /// A color multiplied into the base color. `nil` means white, leaving it unchanged.
    public var baseColorFactor: Color?

    /// A multiplier applied to the metallic texture. `nil` means 1, leaving it unchanged.
    public var metallicFactor: Double?

    /// A multiplier applied to the roughness texture. `nil` means 1, leaving it unchanged.
    public var roughnessFactor: Double?

    /// Creates a set of texture-driven metallic display properties.
    /// - Parameters:
    ///   - id: The resource's id, unique within its model file.
    ///   - name: A name for the appearance.
    ///   - metallicTextureID: The texture holding metallic values.
    ///   - roughnessTextureID: The texture holding roughness values.
    ///   - baseColorFactor: A color multiplied into the base color.
    ///   - metallicFactor: A multiplier for the metallic texture.
    ///   - roughnessFactor: A multiplier for the roughness texture.
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

/// Resolving unset factors.
public extension MetallicTextureDisplayProperties {
    /// The factors actually in force, substituting the spec's defaults for any that aren't set.
    var effectiveFactors: (baseColorFactor: Color, metallicFactor: Double, roughnessFactor: Double) {
        (baseColorFactor ?? .white, metallicFactor ?? 1, roughnessFactor ?? 1)
    }
}
