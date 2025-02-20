import Foundation
import Nodal

// m:texture2dgroup
@XMLCodable
public struct Texture2DGroup: Resource {
    static public let elementName: ExpandedName = Materials.texture2DGroup

    @Attribute(.id) public var id: ResourceID
    @Attribute(.texID) public var texture2DID: ResourceID // "texid", points to a <texture2d>
    @Attribute(.displayPropertiesID) public var displayPropertiesID: ResourceID?  // Points to a <displayproperties>
    @Element(Materials.tex2Coord) public var coordinates: [Coordinate]

    public init(id: ResourceID, texture2DID: ResourceID, displayPropertiesID: ResourceID? = nil, coordinates: [Coordinate]) {
        self.id = id
        self.texture2DID = texture2DID
        self.displayPropertiesID = displayPropertiesID
        self.coordinates = coordinates
    }
}

public extension Texture2DGroup {
    // m:tex2coord
    @XMLCodable
    struct Coordinate {
        @Attribute(.u) public let u: Double
        @Attribute(.v) public let v: Double

        init(u: Double, v: Double) {
            self.u = u
            self.v = v
        }
    }
}
