import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

// m:texture2dgroup
public struct Texture2DGroup: Resource {
    static let elementName = "m:texture2dgroup"

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
}

extension Texture2DGroup: XMLElementComposable {
    static let elementIdentifier = Materials.texture2DGroup

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            .m.id: id,
            .m.texID: texture2DID,
            .m.displayPropertiesID: displayPropertiesID
        ]
    }

    var children: [(any XMLConvertible)?] { coordinates }

    init(xmlElement: XMLElement) throws(Error) {
        id = try xmlElement[.m.id]
        texture2DID = try xmlElement[.m.texID]
        displayPropertiesID = try? xmlElement[.m.displayPropertiesID]
        coordinates = try xmlElement[.m.tex2Coord]
    }
}

public extension Texture2DGroup {
    // m:tex2coord
    struct Coordinate {
        public let u: Double
        public let v: Double

        init(u: Double, v: Double) {
            self.u = u
            self.v = v
        }
    }
}

extension Texture2DGroup.Coordinate: XMLElementComposable {
    static let elementIdentifier = Materials.tex2Coord

    var attributes: [AttributeIdentifier: (any XMLStringConvertible)?] {
        [
            .m.u: u,
            .m.v: v
        ]
    }

    init(xmlElement: XMLElement) throws(Error) {
        u = try xmlElement[.m.u]
        v = try xmlElement[.m.v]
    }
}

