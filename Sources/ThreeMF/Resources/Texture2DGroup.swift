import Foundation
import Nodal

// m:texture2dgroup
public struct Texture2DGroup: Resource, XMLElementCodable {
    static public let elementName: ExpandedName = Materials.texture2DGroup

    public var id: ResourceID
    public var texture2DID: ResourceID // "texid", points to a <texture2d>
    public var displayPropertiesID: ResourceID?  // Points to a <displayproperties>
    public var coordinates: [Coordinate]

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

public extension Texture2DGroup {
    // m:tex2coord
    struct Coordinate: XMLElementCodable {
        public let u: Double
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
