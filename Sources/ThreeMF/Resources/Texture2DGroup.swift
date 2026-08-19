import Foundation
import Nodal

// m:texture2dgroup
/// Texture coordinates that objects and triangles can refer to by index.
///
/// From the materials extension. Each coordinate is a point on a ``Texture2D``; a triangle picks three
/// of them, one per vertex, to map the image onto its surface.
public struct Texture2DGroup: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.texture2DGroup

    public var id: ResourceID

    /// The ``Texture2D`` these coordinates are points on.
    public var texture2DID: ResourceID // "texid", points to a <texture2d>

    /// Display properties describing how the texture should look when rendered, if any.
    public var displayPropertiesID: ResourceID?  // Points to a <displayproperties>

    /// The texture coordinates, referred to by their index in this array.
    public var coordinates: [Coordinate]

    /// Creates a texture coordinate group.
    /// - Parameters:
    ///   - id: The group's id, unique within its model file.
    ///   - texture2DID: The texture these coordinates apply to.
    ///   - displayPropertiesID: Display properties for the texture.
    ///   - coordinates: The coordinates, in index order.
    public init(id: ResourceID, texture2DID: ResourceID, displayPropertiesID: ResourceID? = nil, coordinates: [Coordinate]) {
        self.id = id
        self.texture2DID = texture2DID
        self.displayPropertiesID = displayPropertiesID
        self.coordinates = coordinates
    }

    public func encode(to element: Node) {
        element.setValue(id, forAttribute: .id)
        element.setValue(texture2DID, forAttribute: .texID)
        element.setValue(displayPropertiesID, forAttribute: .displayPropertiesID)
        element.encode(coordinates, elementName: Materials.tex2Coord)
    }

    public init(from element: Node) throws {
        id = try element.value(forAttribute: .id)
        texture2DID = try element.value(forAttribute: .texID)
        displayPropertiesID = try element.value(forAttribute: .displayPropertiesID)
        coordinates = try element.decode(elementName: Materials.tex2Coord)
    }
}

/// A group's texture coordinates.
public extension Texture2DGroup {
    // m:tex2coord
    /// One point on a texture, in the 0–1 range across the image.
    ///
    /// Values outside that range are handled by the texture's ``Texture2D/tileStyleU`` and
    /// ``Texture2D/tileStyleV``.
    struct Coordinate: Sendable, XMLElementCodable {
        /// The horizontal position across the image, from 0 to 1.
        public let u: Double

        /// The vertical position across the image, from 0 to 1.
        public let v: Double

        init(u: Double, v: Double) {
            self.u = u
            self.v = v
        }

        public func encode(to element: Node) {
            element.setValue(u, forAttribute: .u)
            element.setValue(v, forAttribute: .v)
        }

        public init(from element: Node) throws {
            u = try element.value(forAttribute: .u)
            v = try element.value(forAttribute: .v)
        }
    }
}
