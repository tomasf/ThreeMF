import Foundation
import Nodal

// m:pbmetallicdisplayproperties
/// Metallic-roughness appearance for base materials, from the materials extension.
///
/// Display properties say how a material should *look* when rendered. They describe appearance only,
/// and change neither the geometry nor the materials themselves. A material or color group points at
/// one with its display properties id.
public struct MetallicDisplayProperties: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.metallicDisplayProperties

    public var id: ResourceID

    /// The appearances, referred to by their index in this array.
    public var metallics: [Metallic]

    /// Creates a set of metallic display properties.
    /// - Parameters:
    ///   - id: The resource's id, unique within its model file.
    ///   - metallics: The appearances, in index order.
    public init(id: ResourceID, metallics: [Metallic] = []) {
        self.id = id
        self.metallics = metallics
    }

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.encode(metallics, elementName: Materials.metallic)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        metallics = try element.decode(elementName: Materials.metallic)
    }
}

/// Building up the set.
public extension MetallicDisplayProperties {
    @discardableResult

    /// Appends an appearance and returns the index to refer to it by.
    /// - Parameter metallic: The appearance to add.
    /// - Returns: The index of the added appearance.
    mutating func addMetallic(_ metallic: Metallic) -> ResourceIndex {
        metallics.append(metallic)
        return metallics.endIndex - 1
    }
}

// m:pbmetallic
/// One metallic-roughness appearance: how metal-like a surface is, and how rough.
public struct Metallic: Hashable, Sendable, XMLElementCodable {
    /// A name for this appearance.
    public var name: String

    /// How metallic the surface is, from 0 for a dielectric to 1 for bare metal.
    public var metallicness: Double

    /// How rough the surface is, from 0 for a mirror finish to 1 for fully diffuse.
    public var roughness: Double

    /// Creates a metallic appearance.
    /// - Parameters:
    ///   - name: A name for the appearance.
    ///   - metallicness: How metallic the surface is, from 0 to 1.
    ///   - roughness: How rough the surface is, from 0 to 1.
    public init(name: String, metallicness: Double, roughness: Double) {
        self.name = name
        self.metallicness = metallicness
        self.roughness = roughness
    }

    public func encode(to element: Node) {
        element.setValue(name, forAttribute: .name)
        element.setValue(metallicness, forAttribute: .metallicness)
        element.setValue(roughness, forAttribute: .roughness)
    }

    public init(from element: Node) throws {
        name = try element.value(forAttribute: .name)
        metallicness = try element.value(forAttribute: .metallicness)
        roughness = try element.value(forAttribute: .roughness)
    }
}
