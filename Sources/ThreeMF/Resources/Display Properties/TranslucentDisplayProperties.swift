import Foundation
import Nodal

// m:translucentdisplayproperties
/// Translucency for base materials, from the materials extension.
///
/// Display properties say how a material should *look* when rendered. They describe appearance only,
/// and change neither the geometry nor the materials themselves. A material or color group points at
/// one with its display properties id.
public struct TranslucentDisplayProperties: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.translucentDisplayProperties

    public var id: ResourceID

    /// The appearances, referred to by their index in this array.
    public var translucents: [Translucent]

    /// Creates a set of translucent display properties.
    /// - Parameters:
    ///   - id: The resource's id, unique within its model file.
    ///   - translucents: The appearances, in index order.
    public init(id: ResourceID, translucents: [Translucent]) {
        self.id = id
        self.translucents = translucents
    }

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.encode(translucents, elementName: Materials.translucent)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        translucents = try element.decode(elementName: Materials.translucent)
    }
}


// m:translucent
/// One translucent appearance: how light is absorbed and bent as it passes through.
public struct Translucent: Sendable, XMLElementCodable {
    /// A name for this appearance.
    public var name: String

    /// How strongly each color channel is absorbed with distance through the material, as three values.
    public var attenuation: [Double]

    /// The refractive index per color channel, as three values.
    public var refractiveIndices: [Double]

    /// How rough the surface is, from 0 for a clear finish to 1 for fully diffuse. `nil` means 0.
    public var roughness: Double?

    /// Creates a translucent appearance.
    /// - Parameters:
    ///   - name: A name for the appearance.
    ///   - attenuation: How strongly each channel is absorbed with distance.
    ///   - refractiveIndices: The refractive index per channel.
    ///   - roughness: How rough the surface is, from 0 to 1.
    public init(name: String, attenuation: [Double], refractiveIndices: [Double], roughness: Double? = nil) {
        self.name = name
        self.attenuation = attenuation
        self.refractiveIndices = refractiveIndices
        self.roughness = roughness
    }

    public func encode(to element: Node) {
        element.setValue(name, forAttribute: .name)
        element.setValue(attenuation, forAttribute: .attenuation)
        element.setValue(refractiveIndices, forAttribute: .refractiveIndex)
        element.setValue(roughness, forAttribute: .roughness)
    }

    public init(from element: Node) throws {
        name = try element.value(forAttribute: .name)
        attenuation = try element.value(forAttribute: .attenuation)
        refractiveIndices = try element.value(forAttribute: .refractiveIndex)
        roughness = try element.value(forAttribute: .roughness)
    }
}
