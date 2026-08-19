import Foundation
import Nodal

// m:pbspeculardisplayproperties
/// Specular-glossiness appearance for base materials, from the materials extension.
///
/// Display properties say how a material should *look* when rendered. They describe appearance only,
/// and change neither the geometry nor the materials themselves. A material or color group points at
/// one with its display properties id.
public struct SpecularDisplayProperties: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.specularDisplayProperties

    public var id: ResourceID

    /// The appearances, referred to by their index in this array.
    public var speculars: [Specular]

    /// Creates a set of specular display properties.
    /// - Parameters:
    ///   - id: The resource's id, unique within its model file.
    ///   - speculars: The appearances, in index order.
    public init(id: ResourceID, speculars: [Specular] = []) {
        self.id = id
        self.speculars = speculars
    }

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.encode(speculars, elementName: Materials.specular)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        speculars = try element.decode(elementName: Materials.specular)
    }
}

/// Building up the set.
public extension SpecularDisplayProperties {
    @discardableResult

    /// Appends an appearance and returns the index to refer to it by.
    /// - Parameter specular: The appearance to add.
    /// - Returns: The index of the added appearance.
    mutating func addSpecular(_ specular: Specular) -> ResourceIndex {
        speculars.append(specular)
        return speculars.endIndex - 1
    }
}

// m:pbspecular
/// One specular-glossiness appearance: the color of its highlights, and how tight they are.
public struct Specular: Hashable, Sendable, XMLElementCodable {
    /// A name for this appearance.
    public var name: String

    /// The color of the surface's highlights. `nil` uses the spec's default of a dark grey.
    public var specularColor: Color?

    /// How tight the highlights are, from 0 for fully diffuse to 1 for a mirror finish. `nil` means 0.
    public var glossiness: Double?

    /// Creates a specular appearance.
    /// - Parameters:
    ///   - name: A name for the appearance.
    ///   - specularColor: The color of the highlights.
    ///   - glossiness: How tight the highlights are, from 0 to 1.
    public init(name: String, specularColor: Color? = nil, glossiness: Double? = nil) {
        self.name = name
        self.specularColor = specularColor
        self.glossiness = glossiness
    }

    public func encode(to element: Node) {
        element.setValue(name, forAttribute: .name)
        element.setValue(specularColor, forAttribute: .specularColor)
        element.setValue(glossiness, forAttribute: .glossiness)
    }

    public init(from element: Node) throws {
        name = try element.value(forAttribute: .name)
        specularColor = try element.value(forAttribute: .specularColor)
        glossiness = try element.value(forAttribute: .glossiness)
    }
}

/// Resolving unset values.
public extension Specular {
    /// The values actually in force, substituting the spec's defaults for any that aren't set.
    var effectiveValues: (specularColor: Color, glossiness: Double) {
        (specularColor ?? .init(red: 0x38, green: 0x38, blue: 0x38), glossiness ?? 0)
    }
}
